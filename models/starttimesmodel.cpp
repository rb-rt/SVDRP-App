#include "starttimesmodel.h"

StartTimesModel::StartTimesModel(QObject *parent) : QStringListModel(parent)
{
    qDebug("StartTimesModel::StartTimesModel");
    readParam();
}

StartTimesModel::~StartTimesModel()
{
    writeParam();
}

int StartTimesModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;
    return stringList().count();
}

QVariant StartTimesModel::data(const QModelIndex &index, int role) const
{
    //        qInfo("StartTimesModel::data");
    Q_ASSERT(checkIndex(index, QAbstractItemModel::CheckIndexOption::IndexIsValid |
                                   QAbstractItemModel::CheckIndexOption::ParentIsInvalid));

    switch (role) {
    case Qt::DisplayRole: return QStringListModel::data(index,Qt::DisplayRole);
    case Qt::EditRole: return QStringListModel::data(index,Qt::EditRole);
    default: return QVariant();
    }
}

bool StartTimesModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    qDebug("StartTimesModel::setData");
    if (role == Qt::EditRole) {
        if (value.canConvert<QString>()) {
            QString time_s = value.toString();
            QTime time = QTime::fromString(time_s,"hh:mm");
            if (time.isValid()) {
                QStringList liste = stringList();
                int row = index.row();
                if (row >= 0 && row < liste.count()) {
                    liste.replace(row,time_s);
                }
                liste.removeDuplicates();
                if (liste.contains("00:00")) {
                    int i = liste.indexOf("00:00");
                    liste.removeAt(i);
                }
                liste.sort();
                setStringList(liste);
                emit dataChanged(index,index);
                return true;
            }
        }
    }
    return false;
}

void StartTimesModel::addTime(const QString &time)
{
    qDebug("StartTimesModel::addTime");
    //    beginResetModel();
    QStringList liste = stringList();
    if (liste.contains(time)) return;
    liste << time;
    //    m_times.append(time);
    liste.sort();
    setStringList(liste);
    //    endResetModel();
}

void StartTimesModel::delTime(int index)
{
    QStringList liste = stringList();
    if (index >=0 && index < liste.count()) {
        liste.removeAt(index);
        setStringList(liste);
    }
}

void StartTimesModel::readParam()
{
    qDebug() << "StartTimesModel::readParam()";

    QVariant v = m_settings.value("zeiten");
    qDebug() << "Param" << v;
    //    m_times.clear();
    if (v.canConvert<QStringList>()) {
        QStringList liste = v.toStringList();
        liste.removeDuplicates();
        liste.sort();
        //        m_times << liste;
        setStringList(liste);
    }    
}

void StartTimesModel::writeParam()
{
    qDebug() << "StartTimesModel::writeParam()";
    m_settings.setValue("zeiten",stringList());
}


