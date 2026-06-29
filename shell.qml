import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Window

ShellRoot {
    id: root
    property bool showingPanel: false
    PanelWindow {
        id: window
        anchors {
            top: true
            left: true
            right: true
        }
        exclusionMode: ExclusionMode.Auto
        aboveWindows: true

        color: "transparent"
        implicitHeight: 44

        property bool showingWorkspaces: false
        property bool flashActive: false
        property string flashColorValue: "#331a1b26"

        function flashColor(color) {
            flashActive = true
            flashColorValue = color
            colorTimer.restart()
        }

        Timer {
            id: colorTimer
            interval: 600
            onTriggered: window.flashActive = false
        }

        Timer {
            id: hideTimer
            interval: 1500
            onTriggered: {
                window.flashColor("#4d4a3a1e")
                window.showingWorkspaces = false
            }
        }

        Timer {
            id: showPanelTimer
            interval: 400
            onTriggered: controlCenter.visible = true
        }

        // ─── Island Background ───

        Rectangle {
            id: islandBg
            anchors {
                top: parent.top
                topMargin: 4
                horizontalCenter: parent.horizontalCenter
            }
            width: root.showingPanel ? 340
                   : window.showingWorkspaces ? wsRow.implicitWidth + 24
                   : (clockText ? clockText.implicitWidth + 6 : 50) + 24
            height: 32
            radius: 14
            bottomLeftRadius: root.showingPanel ? 0 : 14
            bottomRightRadius: root.showingPanel ? 0 : 14
            color: window.flashActive ? window.flashColorValue
                   : root.showingPanel ? "#4d1a1b26"
                   : "#331a1b26"
            border {
                color: "#1affffff"
                width: 1
            }

            Behavior on width {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.InOutQuad
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 400
                    easing.type: Easing.InOutSine
                }
            }

            Behavior on bottomLeftRadius {
                NumberAnimation {
                    duration: 350
                    easing.type: Easing.InOutQuad
                }
            }

            Behavior on bottomRightRadius {
                NumberAnimation {
                    duration: 350
                    easing.type: Easing.InOutQuad
                }
            }

            // ─── Clock ───

            Item {
                anchors.centerIn: parent
                width: clockText.width + 20
                height: clockText.height
                opacity: !window.showingWorkspaces && !root.showingPanel ? 1 : 0
                visible: opacity > 0
                Behavior on opacity {
                    NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.showingPanel = true
                        showPanelTimer.start()
                    }
                }

                SystemClock {
                    id: clock
                    precision: SystemClock.Minutes
                }

                Text {
                    id: clockText
                    anchors.centerIn: parent
                    text: Qt.formatDateTime(clock.date, "hh:mm")
                    color: "#3dd1b0"
                    font.pixelSize: 13
                    font.bold: true
                }
            }

            // ─── Workspace row ───

            Row {
                id: wsRow
                anchors.centerIn: parent
                opacity: window.showingWorkspaces ? 1 : 0
                visible: opacity > 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.InQuad
                    }
                }
                spacing: 4

                Repeater {
                    model: 9

                    delegate: Item {
                        width: 24
                        height: 22

                        property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)

                        Rectangle {
                            anchors.fill: parent
                            radius: 6
                            color: parent.isActive ? "#3dd1b0" : "#2a2a3a"
                            opacity: parent.isActive ? 0.35 : 0.2
                        }

                        Text {
                            anchors.centerIn: parent
                            text: index + 1
                            color: parent.isActive ? "#3dd1b0" : "#aaaaaa"
                            font.pixelSize: 12
                            font.weight: parent.isActive ? Font.Bold : Font.Normal
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: window.switchToWorkspace(index + 1)
                        }
                    }
                }
            }
        }

        // ─── Switch workspace process ───

        Process {
            id: wsProcess
            command: ["hyprctl", "dispatch", "workspace", "1"]
        }

        function switchToWorkspace(n) {
            wsProcess.command = ["hyprctl", "dispatch", "workspace", String(n)]
            wsProcess.running = false
            wsProcess.running = true
        }

        Connections {
            target: Hyprland
            function onFocusedWorkspaceChanged() {
                if (!window.showingWorkspaces) {
                    window.flashColor("#4d3a1b4e")
                }
                window.showingWorkspaces = true
                hideTimer.restart()
            }
        }
    }

    // ─── ControlCenter popup ───

    ControlCenter {
        id: controlCenter
        anchorItem: islandBg
        visible: false
    }

    Connections {
        target: controlCenter
        function onVisibleChanged() {
            if (!controlCenter.visible) {
                root.showingPanel = false
            }
        }
    }

    // ─── Escape ───

    Shortcut {
        sequence: "Escape"
        context: Qt.ApplicationShortcut
        onActivated: {
            controlCenter.visible = false
        }
    }
}
