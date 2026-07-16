import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Io
import QtQuick
import "./shared" as Pywal

Item {
    id: root
    implicitHeight: 24
    property var pywal: Pywal.Pywal { id: pywalColors }

    signal musicStarted()

    readonly property real barsWidth: 36
    readonly property real controlsWidth: 100
    readonly property real spacing: 6
    implicitWidth: Math.max(320, barsWidth * 2 + controlsWidth + 140 + spacing * 4)

    property var player: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null

    function findActivePlayer() {
        var list = Mpris.players.values
        for (var i = 0; i < list.length; i++) {
            var p = list[i]
            if (p && p.isPlaying) return p
        }
        return list.length > 0 ? list[0] : null
    }

    Connections {
        target: Mpris.players
        function onValuesChanged() {
            var p = findActivePlayer()
            if (p !== root.player) root.player = p
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            var p = findActivePlayer()
            if (p !== root.player) root.player = p
        }
    }

    property string displayText: {
        if (!player) return " \uf001 No player"
        var parts = []
        if (player.trackArtist) parts.push(player.trackArtist)
        if (player.trackTitle) parts.push(player.trackTitle)
        if (parts.length > 0) return " \uf001 " + parts.join(" - ")
        if (player.identity) return " \uf001 " + player.identity
        return " \uf001 Player"
    }

    property var barHeights: [8, 8, 8, 8, 8, 8]

    function updateBars() {
        var t = Date.now() / 1000
        var vol = player ? (player.volume || 0.4) : 0.4
        var newHeights = []
        for (var i = 0; i < 6; i++) {
            var n = Math.sin(t * 5.3 + i * 1.7) * 0.5
                  + Math.sin(t * 2.7 + i * 0.9) * 0.3
                  + Math.random() * 0.2
            var val = 4 + Math.max(0, (0.25 + n * 0.75) * vol) * 18
            newHeights.push(val)
        }
        barHeights = newHeights
    }

    Timer {
        interval: 80
        running: true
        repeat: true
        onTriggered: updateBars()
    }

    Process {
        id: runProc
        command: []
        running: false
    }

    function openFolder() {
        runProc.command = ["sh", "-c", "dir=$(zenity --file-selection --directory --title='Seleccionar música') && [ -n \"$dir\" ] && mpv --no-video \"$dir\""]
        runProc.running = false
        runProc.running = true
        musicStarted()
    }

    Row {
        anchors.centerIn: parent
        anchors.verticalCenter: parent.verticalCenter
        spacing: root.spacing

        Item {
            id: leftBarsWrap
            width: root.barsWidth
            height: 22
            anchors.verticalCenter: parent.verticalCenter
            Row {
                id: leftBars
                anchors.centerIn: parent
                spacing: 3
                Repeater {
                    model: 6
                    Rectangle {
                        width: 3
                        height: root.barHeights[index]
                        radius: 1.5
                        color: pywalColors.color4
                        opacity: 0.8
                        Behavior on height {
                            NumberAnimation { duration: 90; easing.type: Easing.OutQuad }
                        }
                    }
                }
            }
        }

        Item {
            id: textArea
            width: 140
            height: 22
            clip: true
            anchors.verticalCenter: parent.verticalCenter

            Text {
                id: marqueeText
                anchors.verticalCenter: parent.verticalCenter
                text: root.displayText + root.displayText
                color: pywalColors.color4
                font.pixelSize: 12
                font.bold: true
                font.family: "Symbols Nerd Font"

                onTextChanged: {
                    marqueeAnim.stop()
                    x = 0
                    marqueeAnim.start()
                }
                Component.onCompleted: x = 0
            }

            SequentialAnimation {
                id: marqueeAnim
                loops: Animation.Infinite
                running: true

                PropertyAnimation {
                    target: marqueeText
                    property: "x"
                    to: -marqueeText.implicitWidth / 2
                    duration: Math.max(8000, marqueeText.implicitWidth / 2 * 22)
                    easing.type: Easing.Linear
                }

                ScriptAction {
                    script: marqueeText.x = 0
                }
            }
        }

        Row {
            spacing: 2
            anchors.verticalCenter: parent.verticalCenter

            Item {
                width: 22; height: 22
                Rectangle {
                    anchors.fill: parent; radius: 5
                    color: maPrev.containsMouse ? "#22ffffff" : "transparent"
                }
                Text {
                    anchors.centerIn: parent
                    text: "\uf04a"
                    color: maPrev.containsMouse ? pywalColors.color4 : "#aaaaaa"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 12
                }
                MouseArea {
                    id: maPrev
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { if (root.player && root.player.canGoPrevious) root.player.previous() }
                }
            }

            Item {
                width: 22; height: 22
                Rectangle {
                    anchors.fill: parent; radius: 5
                    color: maPlay.containsMouse ? "#22ffffff" : "transparent"
                }
                Text {
                    anchors.centerIn: parent
                    text: root.player && root.player.isPlaying ? "\uf04c" : "\uf04b"
                    color: maPlay.containsMouse ? pywalColors.color4 : "#aaaaaa"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 12
                }
                MouseArea {
                    id: maPlay
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { if (root.player && root.player.canTogglePlaying) root.player.togglePlaying() }
                }
            }

            Item {
                width: 22; height: 22
                Rectangle {
                    anchors.fill: parent; radius: 5
                    color: maNext.containsMouse ? "#22ffffff" : "transparent"
                }
                Text {
                    anchors.centerIn: parent
                    text: "\uf04e"
                    color: maNext.containsMouse ? pywalColors.color4 : "#aaaaaa"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 12
                }
                MouseArea {
                    id: maNext
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { if (root.player && root.player.canGoNext) root.player.next() }
                }
            }

            Item { width: 4; height: 1 }

            Item {
                width: 22; height: 22
                Rectangle {
                    anchors.fill: parent; radius: 5
                    color: maFolder.containsMouse ? "#22ffffff" : "transparent"
                }
                Text {
                    anchors.centerIn: parent
                    text: "\uf07c"
                    color: maFolder.containsMouse ? pywalColors.color4 : "#aaaaaa"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 12
                }
                MouseArea {
                    id: maFolder
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.openFolder()
                }
            }
        }

        Item {
            width: root.barsWidth
            height: 22
            anchors.verticalCenter: parent.verticalCenter
            Row {
                anchors.centerIn: parent
                spacing: 3
                Repeater {
                    model: 6
                    Rectangle {
                        width: 3
                        height: root.barHeights[5 - index]
                        radius: 1.5
                        color: pywalColors.color4
                        opacity: 0.8
                        Behavior on height {
                            NumberAnimation { duration: 90; easing.type: Easing.OutQuad }
                        }
                    }
                }
            }
        }
    }
}
