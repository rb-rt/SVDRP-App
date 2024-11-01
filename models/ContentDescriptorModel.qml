import QtQuick 2.15

ListModel {
    id: contentModel
    ListElement { contentid: 0x10; text: qsTr("Film/Drama"); selected: false }
    ListElement { contentid: 0x11; text: qsTr("Detektiv/Thriller"); selected: false }
    ListElement { contentid: 0x12; text: qsTr("Abenteuer/Western/Krieg"); selected: false }
    ListElement { contentid: 0x13; text: qsTr("Science-Fiction/Fantasy/Horror"); selected: false }
    ListElement { contentid: 0x14; text: qsTr("Komödie"); selected: false }
    ListElement { contentid: 0x15; text: qsTr("Seife/Melodram/Folklore"); selected: false }
    ListElement { contentid: 0x16; text: qsTr("Romanze"); selected: false }
    ListElement { contentid: 0x17; text: qsTr("Ernst/Klassik/Religion/Historischer Film/Drama"); selected: false }
    ListElement { contentid: 0x18; text: qsTr("Erwachsenen-Film/Drama"); selected: false }

    ListElement { contentid: 0x20; text: qsTr("Aktuelle Angelegenheiten"); selected: false }
    ListElement { contentid: 0x21; text: qsTr("Wetterbericht"); selected: false }
    ListElement { contentid: 0x22; text: qsTr("Nachrichtenmagazin"); selected: false }
    ListElement { contentid: 0x23; text: qsTr("Dokumentation"); selected: false }
    ListElement { contentid: 0x24; text: qsTr("Diskussion/Interview/Debatte"); selected: false }

    ListElement { contentid: 0x30; text: qsTr("Show/Spielshow"); selected: false }
    ListElement { contentid: 0x31; text: qsTr("Spielshow/Quiz/Wettbewerb"); selected: false }
    ListElement { contentid: 0x32; text: qsTr("Variete-Show"); selected: false }
    ListElement { contentid: 0x33; text: qsTr("Talkshow"); selected: false }


    ListElement { contentid: 0x40; text: qsTr("Sport"); selected: false }
    ListElement { contentid: 0x41; text: qsTr("Besonderes Ereignis"); selected: false }
    ListElement { contentid: 0x42; text: qsTr("Sportmagazin"); selected: false }
    ListElement { contentid: 0x43; text: qsTr("Football/Fußball"); selected: false }
    ListElement { contentid: 0x44; text: qsTr("Tennis/Squash"); selected: false }
    ListElement { contentid: 0x45; text: qsTr("Mannschaftssport"); selected: false }
    ListElement { contentid: 0x46; text: qsTr("Athletik"); selected: false }
    ListElement { contentid: 0x47; text: qsTr("Motorsport"); selected: false }
    ListElement { contentid: 0x48; text: qsTr("Wassersport"); selected: false }
    ListElement { contentid: 0x49; text: qsTr("Wintersport"); selected: false }
    ListElement { contentid: 0x4a; text: qsTr("Reitsport"); selected: false }
    ListElement { contentid: 0x4b; text: qsTr("Kampfsport"); selected: false }

    ListElement { contentid: 0x50; text: qsTr("Kinder/Jugendprogramm"); selected: false }
    ListElement { contentid: 0x51; text: qsTr("Programm für Vorschulkinder"); selected: false }
    ListElement { contentid: 0x52; text: qsTr("Unterhaltungsprogramm für 6 bis 14"); selected: false }
    ListElement { contentid: 0x53; text: qsTr("Unterhaltungsprogramm für 10 bis 16"); selected: false }
    ListElement { contentid: 0x54; text: qsTr("Informations/Lehr/Schul-Programm"); selected: false }
    ListElement { contentid: 0x55; text: qsTr("Zeichentrick/Puppen"); selected: false }

    ListElement { contentid: 0x60; text: qsTr("Musik/Ballett/Tanz"); selected: false }
    ListElement { contentid: 0x61; text: qsTr("Rock/Pop"); selected: false }
    ListElement { contentid: 0x62; text: qsTr("Ernste/Klassische Musik"); selected: false }
    ListElement { contentid: 0x63; text: qsTr("Volks/Traditionelle Musik"); selected: false }
    ListElement { contentid: 0x64; text: qsTr("Jazz"); selected: false }
    ListElement { contentid: 0x65; text: qsTr("Musical/Oper"); selected: false }
    ListElement { contentid: 0x66; text: qsTr("Ballett"); selected: false }

    ListElement { contentid: 0x70; text: qsTr("Kunst/Kultur"); selected: false }
    ListElement { contentid: 0x71; text: qsTr("Darstellende Künste"); selected: false }
    ListElement { contentid: 0x72; text: qsTr("Bildende Künste"); selected: false }
    ListElement { contentid: 0x73; text: qsTr("Religion"); selected: false }
    ListElement { contentid: 0x74; text: qsTr("Pop-Kultur/Traditionelle Künste"); selected: false }
    ListElement { contentid: 0x75; text: qsTr("Literatur"); selected: false }
    ListElement { contentid: 0x76; text: qsTr("Film/Kino"); selected: false }
    ListElement { contentid: 0x77; text: qsTr("Experimentalfilm/Video"); selected: false }
    ListElement { contentid: 0x78; text: qsTr("Rundfunk/Presse"); selected: false }
    ListElement { contentid: 0x79; text: qsTr("Neue Medien"); selected: false }
    ListElement { contentid: 0x7a; text: qsTr("Kunst/Kulturmagazin"); selected: false }
    ListElement { contentid: 0x7b; text: qsTr("Mode"); selected: false }

    ListElement { contentid: 0x80; text: qsTr("Gesellschaft/Politik/Wirtschaft"); selected: false }
    ListElement { contentid: 0x81; text: qsTr("Magazin/Bericht/Dokumentation"); selected: false }
    ListElement { contentid: 0x82; text: qsTr("Wirtschafts/Gesellschaftsberatung"); selected: false }
    ListElement { contentid: 0x83; text: qsTr("Bemerkenswerte Leute"); selected: false }

    ListElement { contentid: 0x90; text: qsTr("Ausbildung/Wissenschaft/Sachlich"); selected: false }
    ListElement { contentid: 0x91; text: qsTr("Natur/Tiere/Umwelt"); selected: false }
    ListElement { contentid: 0x92; text: qsTr("Technik/Naturwissenschaften"); selected: false }
    ListElement { contentid: 0x93; text: qsTr("Medizin/Physiologie/Psychologie"); selected: false }
    ListElement { contentid: 0x94; text: qsTr("Ausland/Expeditionen"); selected: false }
    ListElement { contentid: 0x95; text: qsTr("Sozial/Geisteswissenschaften"); selected: false }
    ListElement { contentid: 0x96; text: qsTr("Weiterbildung"); selected: false }
    ListElement { contentid: 0x97; text: qsTr("Sprachen"); selected: false }

    ListElement { contentid: 0xa0; text: qsTr("Freizeit/Hobbies"); selected: false }
    ListElement { contentid: 0xa1; text: qsTr("Tourismus/Reisen"); selected: false }
    ListElement { contentid: 0xa2; text: qsTr("Handwerk"); selected: false }
    ListElement { contentid: 0xa3; text: qsTr("Autofahren"); selected: false }
    ListElement { contentid: 0xa4; text: qsTr("Fitness/Gesundheit"); selected: false }
    ListElement { contentid: 0xa5; text: qsTr("Kochen"); selected: false }
    ListElement { contentid: 0xa6; text: qsTr("Werbung/Einkaufen"); selected: false }
    ListElement { contentid: 0xa7; text: qsTr("Gartenbau"); selected: false }

    ListElement { contentid: 0xb0; text: qsTr("Originalsprache"); selected: false }
    ListElement { contentid: 0xb1; text: qsTr("Schwarz-weiß"); selected: false }
    ListElement { contentid: 0xb2; text: qsTr("Unveröffentlicht"); selected: false }
    ListElement { contentid: 0xb3; text: qsTr("Live-Sendung"); selected: false }

    function descriptor() {
        var d = ""
        for(var i=0; i < contentModel.count; i++){
            if (contentModel.get(i).selected) {
                d = d + contentModel.get(i).contentid.toString(16)
            }
        }
        return d
    }

    function reset() {
        for (var i=0; i < count; i++) setProperty(i,"selected",false)
    }

    function getText(contentid) {
        let decimal = parseInt(contentid, 16)
        for(var i=0; i < contentModel.count; i++){
            if (contentModel.get(i).contentid === decimal) return contentModel.get(i).text
        }
        return "nicht vorhanden"
    }
}
