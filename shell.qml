import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Window
import "./shared" as Pywal

ShellRoot {
    id: root
    property var pywal: Pywal.Pywal { id: pywalColors }
    property bool showingPanel: false

    PanelWindow {
        id: panel
        anchors { top: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        aboveWindows: true
        color: "transparent"
        visible: root.showingPanel
        implicitHeight: 520

        Rectangle {
            id: panelBg
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 4
            width: 380
            height: 500
            radius: 14
            color: "#22ffffff"
            border { color: "#30ffffff"; width: 1 }

            opacity: root.showingPanel ? 1 : 0
            scale: root.showingPanel ? 1 : 0.9
            transformOrigin: Item.Top

            Behavior on opacity {
                NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
            }

            Behavior on scale {
                NumberAnimation { duration: 250; easing.type: Easing.OutBack }
            }

            Flickable {
                anchors.fill: parent
                anchors.margins: 12
                contentHeight: panelColumn.height
                clip: true

                Column {
                    id: panelColumn
                    width: parent.width
                    spacing: 6

                    Item {
                        width: parent.width; height: 28
                        Text {
                            anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                            text: "Control Center"
                            color: "#ffffff"
                            font { pixelSize: 14; bold: true }
                        }
                        Rectangle {
                            anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                            width: 22; height: 22; radius: 6; color: "transparent"
                            Text { anchors.centerIn: parent; text: "\u2715"; color: "#ffffff"; font.pixelSize: 12 }
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: root.showingPanel = false
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width; height: 140; color: "transparent"
                        Grid {
                            anchors.centerIn: parent
                            columns: 3; rows: 2; spacing: 8
                            Repeater {
                                model: [
                                    { icon: "\uf023", label: "Bloquear", cmd: ["hyprlock"] },
                                    { icon: "\uf186", label: "Suspender", cmd: ["systemctl", "suspend"] },
                                    { icon: "\uf2dc", label: "Hibernar", cmd: ["systemctl", "hibernate"] },
                                    { icon: "\uf021", label: "Reiniciar", cmd: ["systemctl", "reboot"] },
                                    { icon: "\uf011", label: "Apagar", cmd: ["systemctl", "poweroff"] },
                                    { icon: "\uf2f5", label: "Cerrar sesi\u00f3n", cmd: ["hyprctl", "dispatch", "exit"] }
                                ]
                                delegate: Item {
                                    width: 112; height: 60
                                    Rectangle {
                                        anchors.fill: parent; radius: 10
                                        color: ma.containsMouse ? "#22ffffff" : "transparent"
                                        border { color: ma.containsMouse ? "#30ffffff" : "transparent"; width: 1 }
                                    }
                                    Column {
                                        anchors.centerIn: parent; spacing: 4
                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: modelData.icon; color: pywalColors.color4
                                            font.pixelSize: 20; font.family: "Symbols Nerd Font"
                                        }
                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: modelData.label; color: "#ffffff"; font.pixelSize: 10
                                        }
                                    }
                                    MouseArea {
                                        id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                        onClicked: { powerProcess.command = modelData.cmd; powerProcess.running = false; powerProcess.running = true }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: "#333344" }
                    VolumeSection { id: volSection }
                    Rectangle { width: parent.width; height: 1; color: "#333344" }
                    BrightnessSection { id: brightSection }
                    Rectangle { width: parent.width; height: 1; color: "#333344" }
                    NetworkSection { id: netSection; onRefreshRequested: delayedRefresh.restart() }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            onClicked: root.showingPanel = !root.showingPanel
        }

        Process { id: powerProcess; command: []; running: false }
    }

    Timer {
        id: delayedRefresh
        interval: 500
        onTriggered: { volSection.refresh(); brightSection.refresh(); netSection.refresh() }
    }

    Connections {
        target: root
        function onShowingPanelChanged() {
            if (root.showingPanel) delayedRefresh.start()
        }
    }

    Shortcut { sequence: "Escape"; context: Qt.ApplicationShortcut; onActivated: root.showingPanel = false }
    Shortcut { sequence: "Super+Escape"; context: Qt.ApplicationShortcut; onActivated: root.showingPanel = !root.showingPanel }

    GlobalShortcut {
        appid: "qs-shortcuts"; name: "bar-toggle"; description: "Toggle control panel"
        onPressed: root.showingPanel = !root.showingPanel
    }

    GlobalShortcut {
        appid: "qs-shortcuts"; name: "music-toggle"; description: "Toggle music widget"
        onPressed: {
            ipcToWallclock.command = ["quickshell", "ipc", "-c", "wallclock", "call", "wallclock-control", "toggleMusic"]
            ipcToWallclock.running = false
            ipcToWallclock.running = true
        }
    }

    Process {
        id: ipcToWallclock
        command: []
        running: false
    }
}
