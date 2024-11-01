#include "recordfiltertextmodel.h"
#include "models/recordlistmodel.h"

RecordFilterTextModel::RecordFilterTextModel(QObject *parent) : QSortFilterProxyModel{parent}
{
    setFilterCaseSensitivity(Qt::CaseInsensitive);
}

const QString &RecordFilterTextModel::filterText() const
{
    return m_filterText;
}

void RecordFilterTextModel::setFilterText(QString text)
{
    qDebug() << "RecordFilterTextModel::setFilterText" << text;
    if (text == m_filterText) return;
    m_filterText = text;
    invalidateFilter();
    emit filterTextChanged(text);
}

bool RecordFilterTextModel::filterPath() const
{
    return m_filterPath;
}

void RecordFilterTextModel::setFilterPath(bool newFilterPath)
{
    if (m_filterPath == newFilterPath) return;
    m_filterPath = newFilterPath;
    invalidateFilter();
    emit filterPathChanged();
}

bool RecordFilterTextModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    // qDebug() << "RecordFilterTextModel::filterAcceptsRow filterRole()" << filterRole();

    //true = Anzeige der Reihe, false = ausgefiltert
    if (m_filterText.isEmpty()) return true;
    const QModelIndex &mi = sourceModel()->index(source_row, 0, source_parent);
    const QVariant &v = mi.data(RecordListModel::RecordRole);
    const Record &r = v.value<Record>();
    QString search;
    m_filterPath ? search = r.getName() : search = r.lastName();
    return search.contains(m_filterText,filterCaseSensitivity());
}

