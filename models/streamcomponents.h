#ifndef STREAMCOMPONENTS_H
#define STREAMCOMPONENTS_H

#include <QObject>
#include <QMap>

class StreamComponents : public QObject
{
    Q_OBJECT

public:
    explicit StreamComponents(QObject *parent = nullptr);

    Q_INVOKABLE QString getComponent(int stream, int type);

private:

    QMap<int, QMap<int, QString> > m_streams;

    void createStream01();
    void createStream02();
    void createStream03();
    void createStream04();
    void createStream05();
    void createStream06();
    void createStream07();
    void createStream08();
    void createStream09();
    void createStream10(); //0x0a
    void createStream11(); //0x0b

    QString ac3(int type);

signals:

};

#endif // STREAMCOMPONENTS_H
