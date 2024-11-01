#include "vdrmodel.h"

#include <QDebug>

VDR::VDR()
{}

VDR::VDR(const QVariantMap &vdr)
{
    host = vdr.value("host","unbekannt").toString();
    port = vdr.value("port",6419).toInt();
    streamPort = vdr.value("streamport",0).toInt();
    index = vdr.value("index",-1).toInt();
}

bool VDR::operator==(const VDR &vdr) const
{
    // return (vdr.host == host) && (vdr.port == port);
    return vdr.index == index;
}

QDebug operator << (QDebug dbg, const VDR &vdr)
{
    dbg.space() << "host:" << vdr.host;
    dbg.space() << "port:" << vdr.port;
    dbg.space() << "streamPort:" << vdr.streamPort;
    return dbg.maybeSpace();
}


VdrModel::VdrModel(QObject *parent) : QAbstractListModel(parent)
{
    qDebug("VDRListModel::VDRListModel");
    readHosts();
    qDebug() << "Anzahl:" << m_vdrs.count();
}

VdrModel::~VdrModel()
{
    qDebug("VDRListModel::~VDRListModel");
}


int VdrModel::rowCount(const QModelIndex &parent) const
{
    // For list models only the root node (an invalid parent) should return the list's size. For all
    // other (valid) parents, rowCount() should return 0 so that it does not become a tree model.
    if (parent.isValid()) return 0;
    return m_vdrs.count();
}

QVariant VdrModel::data(const QModelIndex &index, int role) const
{
    //    qDebug("VDRListModel::data");
    Q_ASSERT(checkIndex(index, QAbstractItemModel::CheckIndexOption::IndexIsValid |
                                   QAbstractItemModel::CheckIndexOption::ParentIsInvalid));

    const VDR &vdr = m_vdrs.at(index.row());
    //    qDebug() << vdr.host << vdr.port << "role:" << role;

    switch (role) {
    case Qt::DisplayRole: return QString("http://%1:%2").arg(vdr.host).arg(vdr.port);
    case Roles::HostRole: return vdr.host;
    case Roles::PortRole: return vdr.port;
    case Roles::StreamRole: return vdr.streamPort;
    default: return QVariant();
    }
    return QVariant();
}

bool VdrModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    qDebug("VDRListModel::setData");
    //    qDebug() << "index" << index << "value:" << value;

    if (role != Qt::EditRole) return false;

    if (value.canConvert<VDR>()) {
        VDR vdr_value = value.value<VDR>();
        //        qDebug() << "vdr_value:" << vdr_value;

        int row = index.row();
        m_vdrs.replace(row,vdr_value);

        int size = m_vdrs.count();  //Wichtig, sonst wird die Arraygröße von beginWriteArray auf 1 gesetzt
        m_settings.beginWriteArray("hosts", size);
        m_settings.setArrayIndex(row);
        m_settings.setValue("Host",vdr_value.host);
        m_settings.setValue("Port",vdr_value.port);
        m_settings.setValue("StreamPort",vdr_value.streamPort);
        m_settings.endArray();

        emit dataChanged(index,index);
        return true;
    }
    return false;
}

QHash<int, QByteArray> VdrModel::roleNames() const
{
    QHash<int,QByteArray> roles = QAbstractListModel::roleNames();
    roles[Roles::HostRole] = "host";
    roles[Roles::PortRole] = "port";
    roles[Roles::StreamRole] = "streamport";
    return roles;
}

bool VdrModel::addVdr(const QVariantMap &value)
{
    qDebug("VDRListModel::addVdr");
    VDR vdr(value);
    int rowIndex = rowCount();
    vdr.index = rowIndex;
    beginInsertRows(QModelIndex(), rowIndex, rowIndex);
    m_vdrs.append(vdr);
    endInsertRows();
    QModelIndex index = this->index(rowIndex,0);
    //    qDebug() << "index:" << index;
    QVariant v = QVariant::fromValue<VDR>(vdr);
    return setData(index, v, Qt::EditRole);
}

int VdrModel::currentIndex() const
{
    return m_currentIndex;
}

void VdrModel::setCurrentIndex(int newIndex)
{
    qDebug("VDRListModel::setCurrentIndex");
    // if (m_currentIndex == newIndex) return;
    int index = -1;
    if (0 <= newIndex && newIndex < m_vdrs.count()) {
        index = newIndex;
    }
    else if (m_vdrs.count() > 0) {
        index = 0;
    }
    m_settings.setValue("hosts/defaultHost",index);
    readCurrentHost();
}

bool VdrModel::update(const QVariantMap &value)
{
    qDebug("VDRListModel::update");

    VDR vdr(value);

    int index = m_vdrs.indexOf(vdr);
    if (index == -1) {
        return addVdr(value);
    }
    else {
        QModelIndex mi = this->index(index);
        if (!mi.isValid()) return false;
        QVariant v = QVariant::fromValue<VDR>(vdr);
        return setData(mi, v, Qt::EditRole);
    }
    return false;
}

bool VdrModel::remove(int row)
{
    qDebug("VDRListModel::remove");
    QModelIndex index = this->index(row);
    if (!index.isValid()) return false;
    if (row < 0 || row >= m_vdrs.count()) return false;
    beginResetModel();
    m_vdrs.removeAt(row);

    if (row < m_currentIndex) {
        m_currentIndex--;
        setCurrentIndex(m_currentIndex);
    }

    writeHosts();
    m_vdrs.clear();
    readHosts();
    endResetModel();
    return true;
}

void VdrModel::readHosts()
{
    qDebug("VDRListModel::readHosts");

    int size = m_settings.beginReadArray("hosts");
    for (int i = 0; i < size; ++i) {
        VDR vdr;
        m_settings.setArrayIndex(i);
        vdr.host = m_settings.value("Host").toString();
        vdr.port = m_settings.value("Port",6419).toInt();
        vdr.streamPort = m_settings.value("StreamPort",0).toInt();
        vdr.index = i;
        m_vdrs.append(vdr);
    }
    m_settings.endArray();
}

void VdrModel::writeHosts()
{
    qDebug("VDRListModel::writeHosts");
    m_settings.remove("hosts");
    m_settings.beginWriteArray("hosts");
    int i=0;
    foreach (VDR vdr, m_vdrs) {
        m_settings.setArrayIndex(i);
        m_settings.setValue("Host",vdr.host);
        m_settings.setValue("Port",vdr.port);
        m_settings.setValue("StreamPort",vdr.streamPort);
        i++;
    }
    m_settings.endArray();
}

void VdrModel::readCurrentHost()
{
    qDebug("VdrModel::readCurrentHost");

    //Kein vdr
    m_currentIndex = -1;
    m_currentUrl = QUrl();
    m_streamUrl = QUrl();

    if(m_settings.contains("hosts/defaultHost")) {
        int index = m_settings.value("hosts/defaultHost",-1).toInt();
        if (index >=0 && index < m_vdrs.count()) {
            m_currentIndex = index;
            VDR vdr = m_vdrs.at(m_currentIndex);

            QUrl url;
            url.setScheme("http"); //Wird nie ausgewertet
            url.setHost(vdr.host);
            url.setPort(vdr.port);
            m_currentUrl = url;

            if (vdr.streamPort != 0) {
                url.setPort(vdr.streamPort);
                m_streamUrl = url;
            }
        }
    }
    emit currentIndexChanged();
}

QUrl VdrModel::currentUrl() const
{
    qDebug("VdrModel::currentUrl");
    return m_currentUrl;
}

QUrl VdrModel::streamUrl() const
{
    qDebug() << "VdrModel::streamUrl";
    return m_streamUrl;
}



