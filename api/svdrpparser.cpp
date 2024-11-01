#include "svdrpparser.h"
#include "qregularexpression.h"

SVDRPParser::SVDRPParser(QString line)
{
    parse(line);
}

void SVDRPParser::parse(QString line)
{
    static QRegularExpression regex("^([0-9]{3})(-| )");
    QRegularExpressionMatch match = regex.match(line);
    if(match.hasMatch()) {
        QString c =  match.captured(1);
        QString z = match.captured(2);
        int code = c.toInt();
        if (code == 0) return;
        m_code = code;
        m_lastLine = (code != 220) && (code != 221) && (z == " ");
        m_message = line.remove(0,4);
        m_message.remove("\r");
        m_message.remove("\n");
//        qDebug() << "Lastline" << m_lastLine;
//        qDebug() << "Message" << m_message;
    }
    else {
        m_code = -1;
        if (line.isEmpty()) m_message = ""; else m_message = line;
        m_lastLine = true;
    }
}

int SVDRPParser::code() const
{
    return m_code;
}

QString SVDRPParser::message() const
{
    return m_message;
}

bool SVDRPParser::lastLine() const
{
    return m_lastLine;
}

bool SVDRPParser::isCodeValid() const
{
    return ResponseCodes.contains(m_code);
}

bool SVDRPParser::isErrorCode() const
{
    return (m_code == -1) || ErrorCodes.contains(m_code);
}

