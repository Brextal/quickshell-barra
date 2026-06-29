import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls

PopupWindow {
    id: root
    required property Item anchorItem

    implicitWidth: 340
    implicitHeight: 440
    color: "transparent"
    grabFocus: true

    anchor {
        item: anchorItem
        edges: Edges.Bottom
        gravity: Edges.Bottom
    }

    onVisibleChanged: {
        if (visible) {
            bg.opacity = 0
            Qt.callLater(() => bg.opacity = 1)
            refreshAll()
            refresh.start()
            bg.forceActiveFocus()
        } else {
            bg.opacity = 1
            refresh.stop()
        }
    }

    // ─── Background ───

    Rectangle {
        id: bg
        anchors.fill: parent
        color: "#4d1a1b26"
        radius: 14
        topLeftRadius: 0
        topRightRadius: 0
        border { color: "#1affffff"; width: 1 }
        focus: true
        Keys.onEscapePressed: root.visible = false
        Behavior on opacity {
            NumberAnimation { duration: 500; easing.type: Easing.OutCubic }
        }

        Flickable {
            id: flick
            anchors.fill: parent
            anchors.margins: 12
            contentHeight: column.height
            clip: true
            Keys.onEscapePressed: root.visible = false

            Column {
                id: column
                width: parent.width
                spacing: 6

                ControlCenterHeader {
                    onCloseClicked: root.visible = false
                }

                Rectangle { width: parent.width; height: 1; color: "#2a2a3a" }

                VolumeSection { id: volSection }
                Rectangle { width: parent.width; height: 1; color: "#2a2a3a" }

                BrightnessSection { id: brightSection }
                Rectangle { width: parent.width; height: 1; color: "#2a2a3a" }

                NetworkSection {
                    id: netSection
                    onRefreshRequested: delayedRefresh.restart()
                }
            }
        }
    }

    // ─── Timers ───

    Timer {
        id: refresh
        interval: 3000
        running: root.visible
        repeat: true
        onTriggered: root.refreshAll()
    }

    Timer {
        id: delayedRefresh
        interval: 500
        onTriggered: root.refreshAll()
    }

    function refreshAll() {
        volSection.refresh()
        brightSection.refresh()
        netSection.refresh()
    }
}
