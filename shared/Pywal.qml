import QtQuick
import Quickshell.Io

QtObject {
    id: pywal

    property string color0: "#090404"
    property string color1: "#575139"
    property string color2: "#525637"
    property string color3: "#686740"
    property string color4: "#8e8c65"
    property string color5: "#b1a376"
    property string color6: "#c9b98c"
    property string color7: "#c1c0c0"
    property string color8: "#665353"
    property string color9: "#575139"
    property string color10: "#525637"
    property string color11: "#686740"
    property string color12: "#8e8c65"
    property string color13: "#b1a376"
    property string color14: "#c9b98c"
    property string color15: "#c1c0c0"
    property string foreground: "#c1c0c0"
    property string background: "#090404"

    property string _colorsPath: "/home/brextal/.cache/wal/colors.json"

    function _applyColors(text) {
        try {
            var d = JSON.parse(text)
            if (d.special) {
                pywal.foreground = d.special.foreground || pywal.foreground
                pywal.background = d.special.background || pywal.background
            }
            if (d.colors) {
                pywal.color0 = d.colors.color0 || pywal.color0
                pywal.color1 = d.colors.color1 || pywal.color1
                pywal.color2 = d.colors.color2 || pywal.color2
                pywal.color3 = d.colors.color3 || pywal.color3
                pywal.color4 = d.colors.color4 || pywal.color4
                pywal.color5 = d.colors.color5 || pywal.color5
                pywal.color6 = d.colors.color6 || pywal.color6
                pywal.color7 = d.colors.color7 || pywal.color7
                pywal.color8 = d.colors.color8 || pywal.color8
                pywal.color9 = d.colors.color9 || pywal.color9
                pywal.color10 = d.colors.color10 || pywal.color10
                pywal.color11 = d.colors.color11 || pywal.color11
                pywal.color12 = d.colors.color12 || pywal.color12
                pywal.color13 = d.colors.color13 || pywal.color13
                pywal.color14 = d.colors.color14 || pywal.color14
                pywal.color15 = d.colors.color15 || pywal.color15
            }
        } catch(e) {
            console.error("Pywal: parse error:", e)
        }
    }

    property var _reader: FileView {
        id: fileView
        path: pywal._colorsPath
        watchChanges: true
        onFileChanged: fileView.reload()
        onLoaded: pywal._applyColors(fileView.text())
    }

    Component.onCompleted: _reader.reload()
}
