#ifndef RECORDFILTERTEXTMODEL_H
#define RECORDFILTERTEXTMODEL_H

#include <QSortFilterProxyModel>

class RecordFilterTextModel : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(QString filterText READ filterText WRITE setFilterText NOTIFY filterTextChanged)
    Q_PROPERTY(bool filterPath READ filterPath WRITE setFilterPath NOTIFY filterPathChanged)

public:
    explicit RecordFilterTextModel(QObject *parent = nullptr);

    const QString &filterText() const;
    void setFilterText(QString text); //Zum filtern von Titel und shorttext

    bool filterPath() const;
    void setFilterPath(bool newFilterPath);

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;

private:
    QString m_filterText = "";
    bool m_filterPath = false; //true = sucht im ganzen Pfad, false = nur im Titel

signals:
    void filterTextChanged(QString filterText);
    void filterPathChanged();

};

#endif // RECORDFILTERTEXTMODEL_H
