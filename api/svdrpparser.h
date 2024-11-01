#ifndef SVDRPPARSER_H
#define SVDRPPARSER_H

#include <QObject>

class SVDRPParser
{
public:
    SVDRPParser();
    SVDRPParser(QString line);

    void parse(QString line);

    int code() const;
    QString message() const;
    bool lastLine() const;
    bool isCodeValid() const; //Gültiger Antwortcode? Checkt, ob der Code in der Liste ist
    bool isErrorCode() const; //Fehlercode zurückgegeben?

private:
    QList<int> ResponseCodes = {214, 215, 216, 220, 221, 250, 354, 451, 500, 501, 502, 504, 550, 554, 900 };
    QList<int> ErrorCodes = {500, 501, 502, 504, 550, 554 };

    int m_code = -1; //Responsecode
    QString m_message = ""; //Der String nach dem Responsecode ohne '-'
    bool m_lastLine = false;
};

#endif // SVDRPPARSER_H
