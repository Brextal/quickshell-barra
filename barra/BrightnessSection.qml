import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import "./shared" as Pywal

Column {
    id: brightRoot
    width: parent.width
    spacing: 6
    property var pywal: Pywal.Pywal { id: pywalColors }

    property real brightnessValue: 1
    property bool hasDdcutil: false
    property bool hasBrightness: false

    Text { width: parent.width; color: "#ffffff"; font.pixelSize: 10; text: "\uf185 Brillo"; font.family: "Symbols Nerd Font" }

    Row {
        width: parent.width; height: 34; spacing: 8
        Item { width: 22; height: 22; anchors.verticalCenter: parent.verticalCenter
            Text { anchors.centerIn: parent; text: "\uf185"; font.family: "Symbols Nerd Font"; font.pixelSize: 13; color: pywalColors.color4 } }
        Item {
            width: parent.width - 22 - 36 - 16; height: parent.height
            anchors.verticalCenter: parent.verticalCenter
                Slider {
                id: brightnessSlider
                anchors.centerIn: parent
                from: 0.1; to: 1; value: brightRoot.brightnessValue
                implicitWidth: parent.width; implicitHeight: 20
                enabled: brightRoot.hasDdcutil || brightRoot.hasBrightness
                onMoved: { brightRoot.brightnessValue = value; applyBrightness(value) }
                background: Rectangle {
                    x: brightnessSlider.leftPadding
                    y: brightnessSlider.topPadding + brightnessSlider.availableHeight / 2 - height / 2
                    width: brightnessSlider.availableWidth; height: 4; radius: 2; color: "#333344"
                    Rectangle {
                        width: brightnessSlider.visualPosition * parent.width; height: parent.height
                        radius: 2; color: pywalColors.color5
                    }
                }
                handle: Rectangle {
                    x: brightnessSlider.leftPadding + brightnessSlider.visualPosition * (brightnessSlider.availableWidth - width)
                    y: brightnessSlider.topPadding + brightnessSlider.availableHeight / 2 - height / 2
                    width: 14; height: 14; radius: 7; color: "#ffffff"
                }
            }
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: 36; text: (brightRoot.hasDdcutil || brightRoot.hasBrightness) ? Math.round(brightRoot.brightnessValue * 100) + "%" : "—"
            color: "#ffffff"; font.pixelSize: 11; horizontalAlignment: Text.AlignRight
        }
    }

    Text {
        visible: !brightRoot.hasDdcutil && !brightRoot.hasBrightness
        text: "⚠️ Instala 'brightnessctl' o 'ddcutil' para controlar brillo"
        color: "#ffffff"; font.pixelSize: 9; wrapMode: Text.WordWrap; width: parent.width
    }

    Process {
        id: checkDdcutil
        command: ["which", "ddcutil"]
        running: true
        stdout: StdioCollector { id: ddcCheck; waitForEnd: true }
        onExited: {
            brightRoot.hasDdcutil = ddcCheck.text.trim().length > 0
            if (brightRoot.hasDdcutil) readBrightness.running = true
        }
    }

    Process {
        id: readBrightness
        command: ["ddcutil", "getvcp", "10"]
        running: false
        stdout: StdioCollector { id: brightCollector; waitForEnd: true }
        onExited: {
            var out = brightCollector.text.trim()
            var match = out.match(/current value =\s*(\d+)/)
            if (match) brightRoot.brightnessValue = parseInt(match[1]) / 100
        }
    }

    Process {
        id: setBrightness
        command: []
        running: false
    }

    function applyBrightness(val) {
        if (brightRoot.hasDdcutil) {
            setBrightness.command = ["ddcutil", "setvcp", "10", String(Math.round(val * 100))]
            setBrightness.running = false
            setBrightness.running = true
        } else if (brightRoot.hasBrightness) {
            setBrightnessctl.command = ["brightnessctl", "set", String(Math.round(val * 100)) + "%"]
            setBrightnessctl.running = false
            setBrightnessctl.running = true
        }
    }

    Process {
        id: checkBrightnessctl
        command: ["which", "brightnessctl"]
        running: true
        stdout: StdioCollector { id: brCheck; waitForEnd: true }
        onExited: {
            brightRoot.hasBrightness = brCheck.text.trim().length > 0
            if (brightRoot.hasBrightness) readBrightnessctl.running = true
        }
    }

    Process {
        id: readBrightnessctl
        command: ["sh", "-c", "echo $(($(brightnessctl get) * 100 / $(brightnessctl max)))"]
        running: false
        stdout: StdioCollector { id: brCollector; waitForEnd: true }
        onExited: {
            var out = brCollector.text.trim()
            var val = parseInt(out)
            if (!isNaN(val)) brightRoot.brightnessValue = val / 100
        }
    }

    Process {
        id: setBrightnessctl
        command: []
        running: false
    }

    function refresh() {
        if (brightRoot.hasDdcutil) readBrightness.running = true
        if (brightRoot.hasBrightness) readBrightnessctl.running = true
    }
}
