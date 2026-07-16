import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Window
import Quickshell.Io
import "./shared" as Pywal

PanelWindow {
    id: root

    implicitWidth: 360
    anchors { left: true; top: true; bottom: true }
    exclusiveZone: 0
    aboveWindows: true
    focusable: true
    color: "transparent"
    visible: false
    property var pywal: Pywal.Pywal { id: pywalColors }

    property var allApps: []
    property var filteredApps: []
    property int selectedIndex: 0

    Column {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            width: parent.width
            height: 56
            color: "transparent"

            TextField {
                id: searchField
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    margins: 16
                }
                    height: 36
                    placeholderText: "Buscar aplicación..."
                    placeholderTextColor: "#666666"
                    color: pywalColors.foreground
                    font.pixelSize: 14
                    font.family: "sans-serif"
                background: Rectangle {
                    color: "#401e1e2e"
                    radius: 12
                    border.color: "#601e1e2e"
                    border.width: 1
                }
                leftPadding: 16

                onTextChanged: root.filter(text)

                Keys.onUpPressed: function(event) {
                    event.accepted = true
                    root.moveUp()
                }
                Keys.onDownPressed: function(event) {
                    event.accepted = true
                    root.moveDown()
                }
                Keys.onReturnPressed: function(event) {
                    event.accepted = true
                    root.launchSelected()
                }
                Keys.onEscapePressed: function(event) {
                    event.accepted = true
                    root.close()
                }
            }
        }

        Rectangle {
            width: parent.width - 32
            height: 1
            color: "#30ffffff"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Item {
            id: listContainer
            width: parent.width
                height: parent.height - 56
            clip: true

            MouseArea {
                anchors.fill: parent
                onWheel: function(event) {
                    if (event.angleDelta.y > 0)
                        root.moveUp()
                    else if (event.angleDelta.y < 0)
                        root.moveDown()
                    event.accepted = true
                }
            }

            Repeater {
                id: appRepeater
                anchors.fill: parent
                model: filteredApps

                delegate: AppItem {
                    appName: modelData ? modelData.name : ""
                        appIcon: modelData ? modelData.icon_path : ""
                    isSelected: index === root.selectedIndex
                    distance: index - root.selectedIndex
                    listHeight: listContainer.height
                    onClicked: root.selectedIndex = index
                }
            }
        }
    }

    Component.onCompleted: {
        var path = Qt.resolvedUrl("parse-desktop.sh").toString()
        if (path.startsWith("file://")) path = path.substring(7)
        parserProcess.command = ["/usr/bin/env", "python3", path]
        parserProcess.running = false
        parserProcess.running = true
    }

    function filter(text) {
        if (text === "") {
            filteredApps = allApps
            selectedIndex = 0
            return
        }
        var lower = text.toLowerCase()
        var result = []
        var firstMatch = -1
        for (var i = 0; i < allApps.length; i++) {
            if (allApps[i].name.toLowerCase().indexOf(lower) !== -1) {
                if (firstMatch === -1) firstMatch = result.length
                result.push(allApps[i])
            }
        }
        filteredApps = result
        selectedIndex = firstMatch >= 0 ? firstMatch : 0
    }

    function moveUp() {
        if (selectedIndex > 0) selectedIndex--
    }

    function moveDown() {
        if (selectedIndex < filteredApps.length - 1) selectedIndex++
    }

    function launchSelected() {
        if (filteredApps.length > 0 && selectedIndex >= 0 && selectedIndex < filteredApps.length) {
            var app = filteredApps[selectedIndex]
            launchProcess.command = ["/bin/sh", "-c", app.exec]
            launchProcess.startDetached()
            close()
        }
    }

    function toggle() {
        if (visible) {
            close()
        } else {
            open()
        }
    }

    function open() {
        selectedIndex = 0
        filter("")
        searchField.text = ""
        visible = true
        searchField.forceActiveFocus()
    }

    function close() {
        visible = false
    }

    Process {
        id: parserProcess
        stdout: StdioCollector { id: parserCollector; waitForEnd: true }
        stderr: StdioCollector { id: parserStderr; waitForEnd: true }
        running: false
        onExited: function(code) {
            if (code === 0) {
                var text = parserCollector.text.trim()
                if (text.length > 0) {
                    try {
                        allApps = JSON.parse(text)
                        filteredApps = allApps
                    } catch(e) {
                        console.error("Parser JSON error:", e.toString())
                        console.error("Parser stderr:", parserStderr.text.trim())
                    }
                }
            } else {
                console.error("Parser exited with code:", code)
                console.error("Parser stderr:", parserStderr.text.trim())
            }
        }
    }

    Process {
        id: launchProcess
        running: false
    }
}
