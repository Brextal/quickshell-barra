import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Window

ShellRoot {
    id: root

    property bool showing: false
    property bool weatherLoaded: false
    property string _dir: Qt.resolvedUrl(".").toString().replace("file://", "") + "/"

    PanelWindow {
        id: window
        anchors.top: true
        anchors.left: true
        anchors.right: true
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        visible: root.showing

        implicitHeight: 340

        Item {
            anchors.fill: parent

            Rectangle {
                id: glassBg
                width: 678
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 14
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10
                radius: 18
                color: "#1affffff"
                border {
                    color: "#25ffffff"
                    width: 1
                }

                transformOrigin: Item.Top
                opacity: root.showing ? 1 : 0
                scale: root.showing ? 1 : 0.9

                Behavior on opacity {
                    NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
                }

                Behavior on scale {
                    NumberAnimation { duration: 200; easing.type: Easing.OutBack }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: "transparent"
                    border {
                        color: "#0affffff"
                        width: 1
                    }
                    anchors.margins: 1
                }

                Column {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 2

                    Item {
                        width: parent.width
                        height: 22

                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 8
                            text: {
                                var months = [
                                    "enero", "febrero", "marzo", "abril", "mayo", "junio",
                                    "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"
                                ]
                                var now = new Date()
                                return months[now.getMonth()] + " " + now.getFullYear()
                            }
                            color: "#ffffff"
                            font.pixelSize: 12
                            font.bold: true
                            opacity: 0.8
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.rightMargin: 8
                            text: "\u2190  \u2192  N  \u23CE"
                            color: "#aaaaaa"
                            font.pixelSize: 11
                            opacity: 0.6
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.rightMargin: 80
                            text: root.weatherLoaded ? "\uD83C\uDF26\uFE0F Maip\u00FA" : "\u23F3 clima..."
                            color: "#aaaaaa"
                            font.pixelSize: 10
                            opacity: 0.5
                        }
                    }

                    CalendarStrip {
                        id: strip
                        width: parent.width
                        calendarVisible: root.showing
                        onRequestClose: root.showing = false
                        onNotify: (text) => {
                            notifyProcess.command = ["notify-send", "-a", "Calendario", "-i", "clock", "Recordatorio", text]
                            notifyProcess.running = false
                            notifyProcess.running = true
                        }
                        height: parent.height - 24
                    }
                }
            }
        }
    }

    Process {
        id: weatherProcess
        command: [root._dir + "weather_fetch.sh"]
        running: false

        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                try {
                    var raw = weatherProcess.stdout.text
                    var data = JSON.parse(raw)
                    var daily = data.daily
                    if (!daily) { print("No daily data"); return }

                    var byDay = {}
                    for (var i = 0; i < daily.time.length; i++) {
                        var parts = daily.time[i].split("-")
                        var dayNum = parseInt(parts[2])
                        byDay["" + dayNum] = {
                            code: daily.weathercode[i],
                            temp: Math.round(daily.temperature_2m_max[i]) + "\u00B0"
                        }
                    }
                    strip.weatherByDay = byDay
                    strip.weatherVersion++
                    root.weatherLoaded = true
                    print("Weather OK: " + daily.time.length + " days loaded, day4=" + JSON.stringify(byDay["4"]) + " day5=" + JSON.stringify(byDay["5"]))
                } catch (e) {
                    print("Weather fetch failed: " + e)
                }
            }
        }

        onRunningChanged: {
            if (!running) {
                weatherTimer.restart()
            }
        }
    }

    Connections {
        target: root
        function onShowingChanged() {
            if (root.showing && !root.weatherLoaded) {
                weatherProcess.running = true
            }
        }
    }

    Timer {
        id: weatherTimer
        interval: 30 * 60 * 1000
        running: false
        onTriggered: {
            weatherProcess.running = true
        }
    }

    Process {
        id: notifyProcess
        command: ["notify-send", "-a", "Calendario", "-i", "clock", "Recordatorio", ""]
    }

    Timer {
        id: alarmTimer
        interval: 60000
        running: true
        repeat: true
        onTriggered: {
            try { strip.checkAlarms() } catch (e) { print("Alarm check error: " + e) }
        }
    }

    GlobalShortcut {
        appid: "qs-shortcuts"
        name: "calendar-toggle"
        description: "Toggle calendar"
        onPressed: root.showing = !root.showing
    }


}
