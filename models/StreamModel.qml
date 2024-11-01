import QtQuick 2.15

ListModel {
    ListElement { stream: 0x0;
        components: [
            ListElement { type: 0x00; text: "Reserviert" }
        ]
    }
    ListElement {stream: 0x01;
        components: [
            ListElement { type: 0x01; text: "MPEG-2 Video 4:3 25 Hz" },
            ListElement { type: 0x02; text: "MPEG-2 Video, 16:9 pan, 25 Hz" },
            ListElement { type: 0x03; text: "MPEG-2 Video, 16:9, 25Hz" },
            ListElement { type: 0x04; text: "MPEG-2 Video, > 16:9, 25 Hz" },
            ListElement { type: 0x05; text: "MPEG-2 Video, 4:3, 30 Hz" },
            ListElement { type: 0x06; text: "MPEG-2 Video, 16:9 pan, 30 Hz" },
            ListElement { type: 0x07; text: "MPEG-2 Video, 16:9, 30 Hz" },
            ListElement { type: 0x08; text: "MPEG-2 Video, > 16:9, 30 Hz" },
            ListElement { type: 0x09; text: "MPEG-2 HD Video 4:3 25 Hz" },
            ListElement { type: 0x0a; text: "MPEG-2 HD Video, 16:9 pan, 25 Hz" },
            ListElement { type: 0x0b; text: "MPEG-2 HD Video, 16:9, 25Hz" },
            ListElement { type: 0x0c; text: "MPEG-2 HD Video, > 16:9, 25 Hz" },
            ListElement { type: 0x0d; text: "MPEG-2 HD Video, 4:3, 30 Hz" },
            ListElement { type: 0x0e; text: "MPEG-2 HD Video, 16:9 pan, 30 Hz" },
            ListElement { type: 0x0f; text: "MPEG-2 HD Video, 16:9, 30 Hz" },
            ListElement { type: 0x10; text: "MPEG-2 HD Video, > 16:9, 30 Hz" }
        ]
    }
    ListElement { stream: 0x02;
        components: [
            ListElement { type: 0x01; text: "MPEG1 Layer 2 Audio, Single Mono Kanal" },
            ListElement { type: 0x02; text: "MPEG1 Layer 2 Audio, Dual Mono Kanal" },
            ListElement { type: 0x03; text: "MPEG1 Layer 2 Audio, Stereo (2 Kanäle)" },
            ListElement { type: 0x04; text: "MPEG1 Layer 2 Audio, multi-lingual, multi-channel" },
            ListElement { type: 0x05; text: "MPEG1 Layer 2 Audio, Surround Sound" },
            ListElement { type: 0x40; text: "MPEG1 Layer 2 Audio, Audio Description" },
            ListElement { type: 0x41; text: "MPEG1 Layer 2 Audio, Audio für Hörgeschädigte" },
            ListElement { type: 0x42; text: "receiver-mix" },
            ListElement { type: 0x47; text: "MPEG1 Layer 2 Audio, receiver-mix Audio Description" },
            ListElement { type: 0x48; text: "MPEG1 Layer 2 Audio, broadcast-mix Audio Description" }
        ]
    }
    ListElement { stream: 0x03;
        components: [
            ListElement { type:  0x01; text: "Teletext Untertitel" },
            ListElement { type:  0x02; text: "EBU Teletext" },
            ListElement { type:  0x03; text: "VBI Data" },
            ListElement { type:  0x10; text: "DVB Untertitel" },
            ListElement { type:  0x11; text: "DVB Untertitel 4:3" },
            ListElement { type:  0x12; text: "DVB Untertitel 16:9" },
            ListElement { type:  0x13; text: "DVB Untertitel 2,21:1" },
            ListElement { type:  0x14; text: "DVB Untertitel HD" },
            ListElement { type:  0x15; text: "DVB Untertitel HD plano-stereoscopic" },
            ListElement { type:  0x20; text: "DVB Untertitel für Hörgeschädigte" },
            ListElement { type:  0x21; text: "DVB Untertitel für Hörgeschädigte 4:3" },
            ListElement { type:  0x22; text: "DVB Untertitel für Hörgeschädigte 16:9" },
            ListElement { type:  0x23; text: "DVB Untertitel für Hörgeschädigte 2,21:1" },
            ListElement { type:  0x24; text: "DVB Untertitel für Hörgeschädigte HD" },
            ListElement { type:  0x25; text: "DVB Untertitel für  Hörgeschädigte HD plano-stereoscopic" },
            ListElement { type:  0x30; text: "open (in-vision) sign language" },
            ListElement { type:  0x31; text: "closed sign language for the deaf" },
            ListElement { type:  0x40; text: "video upscaled" },
            ListElement { type:  0x41; text: "Video SDR" },
            ListElement { type:  0x42; text:  "Video SDR -> HDR mapped" },
            ListElement { type:  0x43; text: "Video SDR -> HDR converted" },
            ListElement { type:  0x44; text: "Video <= 60 Hz" },
            ListElement { type:  0x45; text: "Video HFR" },
            ListElement { type:  0x80; text: "dependent SAOC-DE data stream" }
        ]
    }
    ListElement { stream: 0x04;
        channels: [
            ListElement { flag: 0; text: "Mono" },
            ListElement { flag: 1; text: "1+1 Mode" },
            ListElement { flag: 2; text: "2 channel (stereo)" },
            ListElement { flag: 3; text: "2 channel Surround encoded (stereo)" },
            ListElement { flag: 4; text: "Multichannel audio (> 2 channels)" },
            ListElement { flag: 5; text: "Multichannel audio (> 5.1 channels)" },
            ListElement { flag: 6; text: "contains multiple substreams" },
            ListElement { flag: 7; text: "Reserviert" }
        ]
        service: [
            ListElement { flag: 0; text: "Complete Main (CM)" },
            ListElement { flag: 1; text: "Music and Effects (ME)" },
            ListElement { flag: 2; text: "Visually Impaired (VI)" },
            ListElement { flag: 3; text: "Hearing impaired (HI)" },
            ListElement { flag: 4; text: "Dialogue (D)" },
            ListElement { flag: 5; text: "Commentary (C)" },
            ListElement { flag: 6; text: "Emergency (E)" },
            ListElement { flag: 7; text: "Voiceover (VO)" }
        ]
    }
    ListElement { stream: 0x05;
        components: [
            ListElement { type: 0x01; text: "H.264/AVC SD Video, 4:3 25 Hz" },
            ListElement { type: 0x03; text: "H.264/AVC SD Video, 16:9, 25Hz" },
            ListElement { type: 0x04; text: "H.264/AVC SD Video, > 16:9, 25 Hz" },
            ListElement { type: 0x05; text: "H.264/AVC SD Video, 4:3, 30 Hz" },
            ListElement { type: 0x07; text: "H.264/AVC SD Video, 16:9, 30 Hz" },
            ListElement { type: 0x08; text: "H.264/AVC SD Video, > 16:9, 30 Hz" },
            ListElement { type: 0x0b; text: "H.264/AVC HD Video, 16:9, 25Hz" },
            ListElement { type: 0x0c; text: "H.264/AVC HD Video, > 16:9, 25 Hz" },
            ListElement { type: 0x0f; text: "H.264/AVC HD Video, 16:9, 30 Hz" },
            ListElement { type: 0x10; text: "H.264/AVC HD Video, > 16:9, 30 Hz" },
            ListElement { type: 0x80; text: "H.264/AVC HD Video, 16:9, 25 Hz, plano-stereoscopic" }, //0x80
            ListElement { type: 0x81; text: "H.264/AVC HD Video, 16:9, 25 Hz, plano-stereoscopic" },
            ListElement { type: 0x82; text: "H.264/AVC HD Video, 16:9, 30 Hz, plano-stereoscopic" },
            ListElement { type: 0x83; text: "H.264/AVC HD Video, 16:9, 30 Hz, plano-stereoscopic" },
            ListElement { type: 0x84; text: "H.264/MVC HD Video, plano-stereoscopic service compatible video" }
        ]
    }
    ListElement { stream: 0x06;
        components: [
            ListElement { type:  0x01; text: "HE AAC Audio, Single Mono Channel" },
            ListElement { type:  0x03; text: "HE AAC Audio, Stereo" },
            ListElement { type:  0x05; text: "HE AAC Audio, Surround Sound" },
            ListElement { type:  0x40; text: "HE AAC Audio für Sehbehinderte" },
            ListElement { type:  0x41; text: "HE AAC Audio, für Hörgeschädigte" },
            ListElement { type:  0x42; text: "HE AAC Audio, receiver-mix supplementary" },
            ListElement { type:  0x43; text: "HE AAC Audio v2, Stereo" },
            ListElement { type:  0x44; text: "HE AAC Audio v2 für Sehbehinderte" },
            ListElement { type:  0x45; text: "HE AAC Audio v2 für Hörgeschädigte" },
            ListElement { type:  0x46; text: "HE AAC Audio v2, receiver-mix supplementary" },
            ListElement { type:  0x47; text: "HE AAC receiver-mix Audio Description für Sehbehinderte" },
            ListElement { type:  0x48; text: "HE AAC broadcast-mix Audio Description für Sehbehinderte" },
            ListElement { type:  0x49; text: "HE AAC Audio v2, receiver-mix Audio Description für Sehbehinderte" },
            ListElement { type:  0x4a; text: "HE AAC Audio v2, broadcast-mix Audio Description Sehbehinderte" },
            ListElement { type:  0xa0 ; text: "HE AAC Audio, SAOC-DE ancillary data" }
        ]
    }
    ListElement { stream: 0x07;
        components: [
            ListElement { type:  0x01; text: "DTS DTS-HD audio" }
        ]
    }
    ListElement { stream: 0x08;
        components: [
            ListElement { type:  0x01; text: "DVB SRM data" }
        ]
    }
    ListElement { stream: 0x09;
        components: [
            ListElement { type:  0x00; text: "HEVC Main Profile HD Video, 50 Hz" },
            ListElement { type:  0x01; text: "HEVC Main 10 Profile HD Video, 50 Hz" },
            ListElement { type:  0x02; text: "HEVC Main Profile HD Video, 60 Hz" },
            ListElement { type:  0x03; text: "HEVC Main 10 Profile HD Video, 60 Hz" },
            ListElement { type:  0x04; text: "HEVC UHD Video" },
            ListElement { type:  0x05; text: "HEVC UHD Video, HDR" },
            ListElement { type:  0x06; text: "HEVC UHD Video, 100 Hz" },
            ListElement { type:  0x07; text: "HEVC UHD Video, HDR, 100 Hz" }
        ]
    }
    ListElement { stream: 0x0a;
        components: [
            ListElement { type:  0x00; text: "Reserviert" }
        ]
    }
    ListElement { stream: 0x0b;
        components: [
            ListElement { type:  0x00; text: "less than 16:9 aspect ratio" },
            ListElement { type:  0x01; text: "16:9 aspect ratio" },
            ListElement { type:  0x02; text: "greater than 16:9 aspect ratio" },
            ListElement { type:  0x03; text: "plano-stereoscopic top and bottom frame-packing" }
        ]
    }
    function getStream(stream, type) {
        var s = "unbekannt"
        if (stream >= count) return s
        if (stream === 4) {
            s = ac3(type)
        }
        else {
            var comps = get(stream).components
            var index = getIndex(comps,type)
            if (index !== -1) s = comps.get(index).text
        }
        return s
    }
    function getIndex(components,type) {
        for (var i=0; i < components.count; i++) {
            var t = components.get(i).type
            if (t === type) return i
        }
        return -1
    }
    function ac3(type) {
        var channels = get(4).channels
        var b = type & 7 //bits 2 1 0 (letzten 3)
        var ch = channels.get(b).text
        //bits 5 4 3
        type = type >> 3;
        var service = get(4).service
        b = type & 7
        var se = service.get(b).text
        var s = "AC3 Audio: " + ch + " [" + se + "]"
        return s
    }
}
