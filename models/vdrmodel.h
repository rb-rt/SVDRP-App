#ifndef VDRMODEL_H
#define VDRMODEL_H

#include <QAbstractListModel>
#include <QSettings>
#include <QUrl>

class VDR
{
public:
    VDR();
    VDR (const QVariantMap &vdr);
    QString host; //Hostname oder ip-Adresse
    int port;
    int streamPort;
    int index = -1; //nur für Identifizierung

    bool operator==(const VDR &vdr) const;
};
QDebug operator << (QDebug dbg, const VDR &vdr);
Q_DECLARE_METATYPE(VDR)


class VdrModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int currentIndex READ currentIndex WRITE setCurrentIndex NOTIFY currentIndexChanged)
    Q_PROPERTY(QUrl currentUrl READ currentUrl CONSTANT)
    Q_PROPERTY(QUrl streamUrl READ streamUrl CONSTANT)

public:
    explicit VdrModel(QObject *parent = nullptr);
    ~VdrModel();

    enum Roles { HostRole = Qt::UserRole, PortRole, StreamRole };

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;
    QHash<int, QByteArray> roleNames() const override;

    //QML Methoden
    Q_INVOKABLE void readCurrentHost();
    Q_INVOKABLE bool update(const QVariantMap &value);
    Q_INVOKABLE bool remove(int row);

    int currentIndex() const;
    void setCurrentIndex(int newIndex);
    bool addVdr(const QVariantMap &value);

    QUrl currentUrl() const;
    QUrl streamUrl() const;


private:

    int m_currentIndex = -1; //Der momentan ausgewÃ¤hlte VDR
    QUrl m_currentUrl;
    QUrl m_streamUrl;
    QList<VDR> m_vdrs;
    QSettings m_settings; // {"NightWatch","VDR App"};

    void readHosts();
    void writeHosts();

signals:
    void currentIndexChanged();
};


#endif // VDRMODEL_H
