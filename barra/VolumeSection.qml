import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import "./shared" as Pywal

Column {
    id: volRoot
    width: parent.width
    spacing: 6
    property var pywal: Pywal.Pywal { id: pywalColors }

    property real volumeValue: 1
    property bool volumeMuted: false

    Text { width: parent.width; color: "#ffffff"; font.pixelSize: 10; text: "\uf028 Volumen"; font.family: "Symbols Nerd Font" }

    Row {
        width: parent.width; height: 34; spacing: 8
        Item { width: 22; height: 22; anchors.verticalCenter: parent.verticalCenter
            Text {
                anchors.centerIn: parent
                text: volRoot.volumeMuted ? "\uf026" : volRoot.volumeValue < 0.33 ? "\uf027" : "\uf028"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 14
                color: volRoot.volumeMuted ? "#f55" : pywalColors.color4
            } }
        Item {
            width: parent.width - 22 - 30 - 36 - 24; height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            Slider {
                id: volumeSlider
                anchors.centerIn: parent
                from: 0; to: 1; value: volRoot.volumeValue
                implicitWidth: parent.width; implicitHeight: 20
                onMoved: { volRoot.volumeValue = value; applyVolume(value, volRoot.volumeMuted) }
                background: Rectangle {
                    x: volumeSlider.leftPadding
                    y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                    width: volumeSlider.availableWidth; height: 4; radius: 2; color: "#333344"
                    Rectangle {
                        width: volumeSlider.visualPosition * parent.width; height: parent.height
                        radius: 2; color: pywalColors.color4
                    }
                }
                handle: Rectangle {
                    x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                    y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                    width: 14; height: 14; radius: 7; color: "#ffffff"
                }
            }
        }
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 30; height: 22; radius: 6
            color: volRoot.volumeMuted ? "#4a3a3a" : "#1a3a2a"
            Text {
                anchors.centerIn: parent
                text: volRoot.volumeMuted ? "M" : "S"
                color: volRoot.volumeMuted ? "#f55" : pywalColors.color4
                font { pixelSize: 11; bold: true }
            }
            MouseArea {
                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                onClicked: { volRoot.volumeMuted = !volRoot.volumeMuted; applyVolume(volRoot.volumeValue, volRoot.volumeMuted) }
            }
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: 36; text: Math.round(volRoot.volumeValue * 100) + "%"
            color: "#ffffff"; font.pixelSize: 11; horizontalAlignment: Text.AlignRight
        }
    }

    Process {
        id: readVolume
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        running: false
        stdout: StdioCollector { id: volCollector; waitForEnd: true }
        onExited: {
            var out = volCollector.text.trim()
            var match = out.match(/Volume:\s+([\d.]+)/)
            if (match) volRoot.volumeValue = parseFloat(match[1])
            volRoot.volumeMuted = out.indexOf("[MUTED]") >= 0
        }
    }

    Process {
        id: setVolume
        command: []
        running: false
    }

    function applyVolume(val, muted) {
        if (muted) {
            setVolume.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "1"]
        } else {
            setVolume.command = ["sh", "-c", "wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 && wpctl set-volume @DEFAULT_AUDIO_SINK@ " + val]
        }
        setVolume.running = false
        setVolume.running = true
    }

    function refresh() {
        readVolume.running = true
    }
}
