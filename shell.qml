import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Window

ShellRoot {
    id: root
    property bool showingPanel: false
    // ─── Spacer: reserva 44px fijos arriba ───

    PanelWindow {
        id: spacer
        anchors { top: true; left: true; right: true }
        exclusionMode: ExclusionMode.Auto
        implicitHeight: 20
        color: "transparent"
    }

    // ─── Isla flotante (no reserva espacio) ───

    PanelWindow {
        id: window
        anchors { top: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        aboveWindows: true

        color: "transparent"
        implicitHeight: root.showingPanel ? 520 : 36

        property bool showingWorkspaces: false
        property bool flashActive: false
        property string flashColorValue: "#3dd1b033"

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
                window.flashColor("#3dd1b033")
                window.showingWorkspaces = false
            }
        }

        // ─── Island Background ───

        Rectangle {
            id: islandBg
            anchors {
                top: parent.top
                topMargin: 4
                horizontalCenter: parent.horizontalCenter
            }
            width: root.showingPanel ? 380
                   : window.showingWorkspaces ? wsRow.implicitWidth + 24
                   : (clockText ? clockText.implicitWidth + 6 : 50) + 24
            height: root.showingPanel ? 500 : 32
            radius: 14
            bottomLeftRadius: root.showingPanel ? 14 : 14
            bottomRightRadius: root.showingPanel ? 14 : 14
            color: window.flashActive ? window.flashColorValue
                   : root.showingPanel ? "#22ffffff"
                   : "#18ffffff"
            border {
                color: "#30ffffff"
                width: 1
            }

            Behavior on width {
                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }

            Behavior on color {
                ColorAnimation { duration: 200; easing.type: Easing.InOutSine }
            }

            Behavior on bottomLeftRadius {
                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }

            Behavior on bottomRightRadius {
                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }

            Behavior on height {
                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }

            // ─── Clock (only when closed) ───

            Item {
                anchors.centerIn: parent
                width: clockText.width + 20
                height: clockText.height
                opacity: !window.showingWorkspaces && !root.showingPanel ? 1 : 0
                visible: opacity > 0
                Behavior on opacity {
                    NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.showingPanel = true
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
                    NumberAnimation { duration: 120; easing.type: Easing.InQuad }
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
                            color: parent.isActive ? "#3dd1b0" : "#18ffffff"
                            opacity: parent.isActive ? 0.35 : 0.3
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

            // ─── Extended panel content ───

            Item {
                anchors.fill: parent
                anchors.margins: 12
                opacity: root.showingPanel ? 1 : 0
                visible: opacity > 0
                Behavior on opacity {
                    NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
                }

                Flickable {
                    anchors.fill: parent
                    contentHeight: panelColumn.height
                    clip: true

                    Column {
                        id: panelColumn
                        width: parent.width
                        spacing: 6

                        // ─── Header ───

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
                                Text { anchors.centerIn: parent; text: "✕"; color: "#ffffff"; font.pixelSize: 12 }
                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: root.showingPanel = false
                                }
                            }
                        }

                        // ─── Power grid ───

                        Rectangle {
                            width: parent.width
                            height: 140
                            color: "transparent"

                            Grid {
                                anchors.centerIn: parent
                                columns: 3
                                rows: 2
                                spacing: 8

                                Repeater {
                                    model: [
                                        { icon: "\uf023", label: "Bloquear", cmd: ["hyprlock"] },
                                        { icon: "\uf186", label: "Suspender", cmd: ["systemctl", "suspend"] },
                                        { icon: "\uf2dc", label: "Hibernar", cmd: ["systemctl", "hibernate"] },
                                        { icon: "\uf021", label: "Reiniciar", cmd: ["systemctl", "reboot"] },
                                        { icon: "\uf011", label: "Apagar", cmd: ["systemctl", "poweroff"] },
                                        { icon: "\uf2f5", label: "Cerrar sesión", cmd: ["hyprctl", "dispatch", "exit"] }
                                    ]

                                    delegate: Item {
                                        width: 112
                                        height: 60

                                        Rectangle {
                                            anchors.fill: parent
                                            radius: 10
                                            color: ma.containsMouse ? "#22ffffff" : "transparent"
                                            border { color: ma.containsMouse ? "#30ffffff" : "transparent"; width: 1 }
                                        }

                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 4

                                            Text {
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                text: modelData.icon
                                                color: "#3dd1b0"
                                                font.pixelSize: 20
                                                font.family: "Symbols Nerd Font"
                                            }

                                            Text {
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                text: modelData.label
                                                color: "#ffffff"
                                                font.pixelSize: 10
                                            }
                                        }

                                        MouseArea {
                                            id: ma
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                powerProcess.command = modelData.cmd
                                                powerProcess.running = false
                                                powerProcess.running = true
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle { width: parent.width; height: 1; color: "#333344" }

                        // ─── Volume ───

                        VolumeSection { id: volSection }
                        Rectangle { width: parent.width; height: 1; color: "#333344" }

                        // ─── Brightness ───

                        BrightnessSection { id: brightSection }
                        Rectangle { width: parent.width; height: 1; color: "#333344" }

                        // ─── Network ───

                        NetworkSection {
                            id: netSection
                            onRefreshRequested: delayedRefresh.restart()
                        }
                    }
                }
            }
        }

        // ─── Right-click power toggle ───

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.showingPanel = !root.showingPanel
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

        Process {
            id: powerProcess
            command: []
            running: false
        }

        Connections {
            target: Hyprland
            function onFocusedWorkspaceChanged() {
                if (!window.showingWorkspaces) {
                    window.flashColor("#3dd1b033")
                }
                window.showingWorkspaces = true
                hideTimer.restart()
            }
        }
    }

    // ─── Timers ───

    Timer {
        id: delayedRefresh
        interval: 500
        onTriggered: {
            volSection.refresh()
            brightSection.refresh()
            netSection.refresh()
        }
    }

    Connections {
        target: root
        function onShowingPanelChanged() {
            if (root.showingPanel) {
                delayedRefresh.start()
            }
        }
    }

    // ─── Escape ───

    Shortcut {
        sequence: "Escape"
        context: Qt.ApplicationShortcut
        onActivated: {
            root.showingPanel = false
        }
    }

    Shortcut {
        sequence: "Super+Escape"
        context: Qt.ApplicationShortcut
        onActivated: {
            root.showingPanel = !root.showingPanel
        }
    }

    GlobalShortcut {
        appid: "qs-shortcuts"
        name: "bar-toggle"
        description: "Toggle control panel"
        onPressed: root.showingPanel = !root.showingPanel
    }
}
