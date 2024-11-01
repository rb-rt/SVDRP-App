#include "streamcomponents.h"
#include "qdebug.h"

StreamComponents::StreamComponents(QObject *parent) : QObject{parent}
{
    createStream01();
    createStream02();
    createStream03();
    createStream04();
    createStream05();
    createStream06();
    createStream07();
    createStream08();
    createStream09();
    createStream10(); //0x0a
    createStream11(); //0x0b
}

QString StreamComponents::getComponent(int stream, int type)
{
    QString s = "unbekannt";
    if (m_streams.contains(stream)) {

        if (stream == 4) {
            s = ac3(type);
        }
        else {

        QMap<int, QString> components = m_streams.value(stream);
        if (components.contains(type)) {
            s = components.value(type);
        }
        }
    }
    return s;
}

void StreamComponents::createStream01()
{
    QMap<int, QString> components;
    bool ok;
    components.insert(QString("01").toInt(&ok,16), "MPEG-2 Video 4:3 25 Hz");
    components.insert(QString("02").toInt(&ok,16), "MPEG-2 Video, 16:9 pan, 25 Hz");
    components.insert(QString("03").toInt(&ok,16), "MPEG-2 Video, 16:9, 25Hz");
    components.insert(QString("04").toInt(&ok,16), "MPEG-2 Video, > 16:9, 25 Hz");
    components.insert(QString("05").toInt(&ok,16), "MPEG-2 Video, 4:3, 30 Hz");
    components.insert(QString("06").toInt(&ok,16), "MPEG-2 Video, 16:9 pan, 30 Hz");
    components.insert(QString("07").toInt(&ok,16), "MPEG-2 Video, 16:9, 30 Hz");
    components.insert(QString("08").toInt(&ok,16), "MPEG-2 Video, > 16:9, 30 Hz");
    components.insert(QString("09").toInt(&ok,16), "MPEG-2 HD Video 4:3 25 Hz");
    components.insert(QString("0a").toInt(&ok,16), "MPEG-2 HD Video, 16:9 pan, 25 Hz");
    components.insert(QString("0b").toInt(&ok,16), "MPEG-2 HD Video, 16:9, 25Hz");
    components.insert(QString("0c").toInt(&ok,16), "MPEG-2 HD Video, > 16:9, 25 Hz");
    components.insert(QString("0d").toInt(&ok,16), "MPEG-2 HD Video, 4:3, 30 Hz");
    components.insert(QString("0e").toInt(&ok,16), "MPEG-2 HD Video, 16:9 pan, 30 Hz");
    components.insert(QString("0f").toInt(&ok,16), "MPEG-2 HD Video, 16:9, 30 Hz");
    components.insert(QString("10").toInt(&ok,16), "MPEG-2 HD Video, > 16:9, 30 Hz");
    m_streams.insert(1, components);
}

void StreamComponents::createStream02()
{
    QMap<int, QString> components;
    bool ok;
    components.insert(QString("01").toInt(&ok,16), "MPEG1 Layer 2 Audio, Single Mono Kanal" );
    components.insert(QString("02").toInt(&ok,16), "MPEG1 Layer 2 Audio, Dual Mono Kanal" );
    components.insert(QString("03").toInt(&ok,16), "MPEG1 Layer 2 Audio, Stereo (2 Kanäle)" );
    components.insert(QString("04").toInt(&ok,16), "MPEG1 Layer 2 Audio, multi-lingual, multi-channel" );
    components.insert(QString("05").toInt(&ok,16), "MPEG1 Layer 2 Audio, Surround Sound" );
    components.insert(QString("40").toInt(&ok,16), "MPEG1 Layer 2 Audio, Audio Description für Sehbehinderte" );
    components.insert(QString("41").toInt(&ok,16), "MPEG1 Layer 2 Audio, Audio für Hörgeschädigte" );
    components.insert(QString("42").toInt(&ok,16), "receiver-mix" );
    components.insert(QString("47").toInt(&ok,16), "MPEG1 Layer 2 Audio, receiver-mix Audio Description" );
    components.insert(QString("48").toInt(&ok,16), "MPEG1 Layer 2 Audio, broadcast-mix Audio Description" );
    m_streams.insert(2,components);
}

void StreamComponents::createStream03()
{
    QMap<int, QString> components;
    bool ok;
    components.insert(QString("01").toInt(&ok,16), "Teletext Untertitel" );
    components.insert(QString("02").toInt(&ok,16), "EBU Teletext" );
    components.insert(QString("03").toInt(&ok,16), "VBI data" );
    components.insert(QString("10").toInt(&ok,16), "DVB Untertitel" );
    components.insert(QString("11").toInt(&ok,16), "DVB Untertitel 4:3" );
    components.insert(QString("12").toInt(&ok,16), "DVB Untertitel 16:9" );
    components.insert(QString("13").toInt(&ok,16), "DVB Untertitel 2,21:1" );
    components.insert(QString("14").toInt(&ok,16), "DVB Untertitel HD" );
    components.insert(QString("15").toInt(&ok,16), "DVB Untertitel HD plano-stereoscopic" );
    components.insert(QString("20").toInt(&ok,16), "DVB Untertitel für Hörgeschädigte" );
    components.insert(QString("21").toInt(&ok,16), "DVB Untertitel für Hörgeschädigte 4:3" );
    components.insert(QString("22").toInt(&ok,16), "DVB Untertitel für Hörgeschädigte 16:9" );
    components.insert(QString("23").toInt(&ok,16), "DVB Untertitel für Hörgeschädigte 2,21:1" );
    components.insert(QString("24").toInt(&ok,16), "DVB Untertitel für Hörgeschädigte HD" );
    components.insert(QString("25").toInt(&ok,16), "DVB Untertitel für  Hörgeschädigte HD plano-stereoscopic" );
    components.insert(QString("30").toInt(&ok,16), "open (in-vision) sign language for the deaf" );
    components.insert(QString("31").toInt(&ok,16), "closed sign language for the deaf" );
    components.insert(QString("40").toInt(&ok,16), "video upscaled" );
    components.insert(QString("41").toInt(&ok,16), "Video SDR" );
    components.insert(QString("42").toInt(&ok,16), "Video SDR -> HDR mapped" );
    components.insert(QString("43").toInt(&ok,16), "Video SDR -> HDR converted" );
    components.insert(QString("44").toInt(&ok,16), "Video <= 60 Hz" );
    components.insert(QString("45").toInt(&ok,16), "Video HFR" );
    components.insert(QString("80").toInt(&ok,16), "dependent SAOC-DE data stream" );
    m_streams.insert(3,components);
}

void StreamComponents::createStream04()
{
    QMap<int, QString> components;
    components.insert(1,"AC3 audio");
    m_streams.insert(4, components);
}

void StreamComponents::createStream05()
{
    QMap<int, QString> components;
    bool ok;
    components.insert(QString("01").toInt(&ok,16), "H.264/AVC SD Video 4:3 25 Hz" );
    components.insert(QString("03").toInt(&ok,16), "H.264/AVC SD Video, 16:9, 25Hz" );
    components.insert(QString("04").toInt(&ok,16), "H.264/AVC SD Video, > 16:9, 25 Hz" );
    components.insert(QString("05").toInt(&ok,16), "H.264/AVC SD Video, 4:3, 30 Hz" );
    components.insert(QString("07").toInt(&ok,16), "H.264/AVC SD Video, 16:9, 30 Hz" );
    components.insert(QString("08").toInt(&ok,16), "H.264/AVC SD Video, > 16:9, 30 Hz" );
    components.insert(QString("0b").toInt(&ok,16), "H.264/AVC HD Video, 16:9, 25Hz" );
    components.insert(QString("0c").toInt(&ok,16), "H.264/AVC HD Video, > 16:9, 25 Hz" );
    components.insert(QString("0f").toInt(&ok,16), "H.264/AVC HD Video, 16:9, 30 Hz" );
    components.insert(QString("10").toInt(&ok,16), "H.264/AVC HD Video, > 16:9, 30 Hz" );
    components.insert(QString("80").toInt(&ok,16), "H.264/AVC HD Video, 16:9, 25 Hz, plano-stereoscopic" ); //0x80
    components.insert(QString("81").toInt(&ok,16), "H.264/AVC HD Video, 16:9, 25 Hz, plano-stereoscopic" );
    components.insert(QString("82").toInt(&ok,16), "H.264/AVC HD Video, 16:9, 30 Hz, plano-stereoscopic" );
    components.insert(QString("83").toInt(&ok,16), "H.264/AVC HD Video, 16:9, 30 Hz, plano-stereoscopic" );
    components.insert(QString("84").toInt(&ok,16), "H.264/MVC HD Video, plano-stereoscopic service compatible video");
    m_streams.insert(5,components);
}

void StreamComponents::createStream06()
{
    QMap<int, QString> components;
    bool ok;
    components.insert(QString("01").toInt(&ok,16), "HE AAC Audio, Single Mono Channel" );
    components.insert(QString("03").toInt(&ok,16), "HE AAC Audio, Stereo" );
    components.insert(QString("05").toInt(&ok,16), "HE AAC Audio, Surround Sound" );
    components.insert(QString("40").toInt(&ok,16), "HE AAC Audio für Sehbehinderte" ); //0x40
    components.insert(QString("41").toInt(&ok,16), "HE AAC Audio für Hörgeschädigte" ); //0x41
    components.insert(QString("42").toInt(&ok,16), "HE AAC Audio, receiver-mix supplementary" );
    components.insert(QString("43").toInt(&ok,16), "HE AAC Audio v2, Stereo" );
    components.insert(QString("44").toInt(&ok,16), "HE AAC Audio v2 für Sehbehinderte");
    components.insert(QString("45").toInt(&ok,16), "HE AAC Audio v2 für Hörgeschädigte" );
    components.insert(QString("46").toInt(&ok,16), "HE AAC Audio v2, receiver-mix supplementary" );
    components.insert(QString("47").toInt(&ok,16), "HE AAC receiver-mix Audio Description für Sehbehinderte" );
    components.insert(QString("48").toInt(&ok,16), "HE AAC broadcast-mix Audio Description für Sehbehinderte" );
    components.insert(QString("49").toInt(&ok,16), "HE AAC Audio v2, receiver-mix Audio Description für Sehbehinderte" );
    components.insert(QString("4a").toInt(&ok,16), "HE AAC Audio v2, broadcast-mix Audio Description Sehbehinderte" );
    components.insert(QString("a0").toInt(&ok,16), "HE AAC Audio, SAOC-DE ancillary data" );
    m_streams.insert(6,components);
}

void StreamComponents::createStream07()
{
    QMap<int, QString> components;
    components.insert(1,"DTS DTS-HD audio");
    m_streams.insert(7, components);
}

void StreamComponents::createStream08()
{
    QMap<int, QString> components;
    components.insert(1,"DVB SRM data");
    m_streams.insert(8, components);
}

void StreamComponents::createStream09()
{
    QMap<int, QString> components;
    bool ok;
    components.insert(QString("00").toInt(&ok,16), "HEVC Main Profile HD Video, 50 Hz" );
    components.insert(QString("01").toInt(&ok,16), "HEVC Main 10 Profile HD Video, 50 Hz" );
    components.insert(QString("02").toInt(&ok,16), "HEVC Main Profile HD Video, 60 Hz" );
    components.insert(QString("03").toInt(&ok,16), "HEVC Main 10 Profile HD Video, 60 Hz" );
    components.insert(QString("04").toInt(&ok,16), "HEVC UHD Video" );
    components.insert(QString("05").toInt(&ok,16), "HEVC UHD Video, HDR" );
    components.insert(QString("06").toInt(&ok,16), "HEVC UHD Video, 100 Hz" );
    components.insert(QString("07").toInt(&ok,16), "HEVC UHD Video, HDR, 100 Hz" );
    m_streams.insert(9,components);
}

void StreamComponents::createStream10()
{
    QMap<int, QString> components;
    components.insert(0,"Reserviert");
    m_streams.insert(10, components);
}

void StreamComponents::createStream11()
{
    QMap<int, QString> components;
    bool ok;
    components.insert(QString("00").toInt(&ok,16), "less than 16:9 aspect ratio" );
    components.insert(QString("01").toInt(&ok,16), "16:9 aspect ratio" );
    components.insert(QString("02").toInt(&ok,16), "greater than 16:9 aspect ratio" );
    components.insert(QString("03").toInt(&ok,16), "plano-stereoscopic top and bottom frame-packing" );
    m_streams.insert(11,components);
}

QString StreamComponents::ac3(int type)
{
//    qDebug() << "Type" << type;
    QString ch;
    int channels = type & 7; //bits 2 1 0 (letzten 3)
    switch (channels) {
    case 0: ch = "Mono"; break;
    case 1: ch = "1+1 Mode"; break;
    case 2: ch = "2 channel (stereo)"; break;
    case 3: ch = "2 channel Surround encoded (stereo)"; break;
    case 4: ch = "Multichannel audio (> 2 channels)"; break;
    case 5: ch = "Multichannel audio (> 5.1 channels)"; break;
    case 6: ch = "contains multiple substreams"; break;
    case 7: ch = "Reserviert"; break;
    default: ch = "unbekannt";
    }
//    qDebug() << "Channels" << ch;
    //bits 5 4 3
    type = type >> 3;
    int service = type & 7;
    QString se;
    switch (service) {
    case 0: se = "Complete Main (CM)"; break;
    case 1: se = "Music and Effects (ME)"; break;
    case 2: se = "Visually Impaired (VI)"; break;
    case 3: se = "Hearing impaired (HI)"; break;
    case 4: se = "Dialogue (D)"; break;
    case 5: se = "Commentary (C)"; break;
    case 6: se = "Emergency (E)"; break;
    case 7: se = "Voiceover (VO)"; break;
    default: se = "unbekannt";
    }
//    qDebug() << "Service" << se;
//    int d = type & 64; //bits 6
//    qDebug() << "D" << d;
    QString s = "AC3 Audio: " + ch + " [" + se + "]";
     //bits 7
    if ((type & 128) == 128) {
        s = s + " (E-AC3)";
    }
    return s;
}
