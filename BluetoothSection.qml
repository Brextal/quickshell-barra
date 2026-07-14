import Quickshell
import Quickshell.Io
import QtQuick
import "./shared" as Pywal

Column {
    id: btRoot
    width: parent.width
    spacing: 6
    property var pywal: Pywal.Pywal { id: pywalColors }

    property bool btOn: false
    property string btAlias: ""
    property bool btDiscoverable: false
    property bool btPairable: false
    property var btDevices: []

    signal refreshRequested()

    Text { width: parent.width; color: "#888"; font.pixelSize: 10; text: " 🔷 Bluetooth" }

    Item {
        width: parent.width; height: 28
        Row {
            anchors.verticalCenter: parent.verticalCenter; spacing: 8
            Text { anchors.verticalCenter: parent.verticalCenter; text: "\uf294"; font.family: "Symbols Nerd Font"; font.pixelSize: 14; color: "#ffffff" }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: btOn ? "Encendido" : "Apagado"
                color: btOn ? pywalColors.color4 : "#f55"
                font.pixelSize: 12
            }
        }
            Rectangle {
                anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                width: 36; height: 20; radius: 10
                color: btOn ? pywalColors.color4 : "#3a3a3a"
                Behavior on color { ColorAnimation { duration: 150 } }
                Rectangle {
                    x: btOn ? parent.width - width - 2 : 2
                    anchors.verticalCenter: parent.verticalCenter
                    width: 16; height: 16; radius: 8; color: "white"
                    Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                }
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: toggleBt()
                }
            }
        }

    Item {
        width: parent.width; height: 26
        visible: btOn
        Row {
            anchors.verticalCenter: parent.verticalCenter; spacing: 8
            Text { text: "Nombre:"; color: "#888"; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
            Rectangle {
                width: 140; height: 22; radius: 6; color: "#18ffffff"
                border { color: "#30ffffff"; width: 1 }
                TextInput {
                    id: aliasInput
                    anchors.fill: parent; anchors.margins: 4
                    text: btAlias
                    color: "#ffffff"; font.pixelSize: 11
                    selectByMouse: true
                }
            }
            Rectangle {
                width: 40; height: 22; radius: 6; color: pywalColors.color4
                Text { anchors.centerIn: parent; text: "✓"; color: "white"; font { pixelSize: 12; bold: true } }
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: applyAlias(aliasInput.text)
                }
            }
        }
    }

    Item {
        width: parent.width; height: 26
        visible: btOn
        Row {
            anchors.verticalCenter: parent.verticalCenter; spacing: 8
            Text { text: "Descubrible:"; color: "#888"; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
            Rectangle {
                anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                width: 36; height: 20; radius: 10
                color: btDiscoverable ? pywalColors.color4 : "#3a3a3a"
                Behavior on color { ColorAnimation { duration: 150 } }
                Rectangle {
                    x: btDiscoverable ? parent.width - width - 2 : 2
                    anchors.verticalCenter: parent.verticalCenter
                    width: 16; height: 16; radius: 8; color: "white"
                    Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                }
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: toggleDiscoverable()
                }
            }
        }
    }

    Item {
        width: parent.width; height: 26
        visible: btOn
        Row {
            anchors.verticalCenter: parent.verticalCenter; spacing: 8
            Text { text: "Emparejable:"; color: "#888"; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
            Rectangle {
                anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                width: 36; height: 20; radius: 10
                color: btPairable ? pywalColors.color4 : "#3a3a3a"
                Behavior on color { ColorAnimation { duration: 150 } }
                Rectangle {
                    x: btPairable ? parent.width - width - 2 : 2
                    anchors.verticalCenter: parent.verticalCenter
                    width: 16; height: 16; radius: 8; color: "white"
                    Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                }
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: togglePairable()
                }
            }
        }
    }

    Item {
        width: parent.width
        height: btOn ? Math.min(btList.height, 100) : 0
        clip: true
        Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }

        Column {
            id: btList
            width: parent.width
            Repeater {
                model: btDevices
                delegate: Item {
                    width: parent.width; height: 24
                    Row {
                        anchors.verticalCenter: parent.verticalCenter; spacing: 6
                        anchors.left: parent.left; anchors.leftMargin: 8
                        Text {
                            text: "●"; font.pixelSize: 8
                            anchors.verticalCenter: parent.verticalCenter
                            color: modelData.connected ? pywalColors.color4 : "#555"
                        }
                        Text {
                            text: modelData.name || modelData.address
                            color: "#ffffff"; font.pixelSize: 11
                            width: 160; elide: Text.ElideRight
                        }
                        Text {
                            text: modelData.connected ? "Conectado" : "No conect."
                            color: modelData.connected ? pywalColors.color4 : "#888"
                            font.pixelSize: 10
                        }
                    }
                }
            }
            Text {
                visible: btDevices.length === 0
                text: "Sin dispositivos emparejados"
                color: "#666"; font.pixelSize: 10; leftPadding: 8
            }
        }
    }

    Process {
        id: readBtState
        command: ["bluetoothctl", "show"]
        running: false
        stdout: StdioCollector { id: btCollector; waitForEnd: true }
        onExited: {
            var text = btCollector.text
            btOn = text.indexOf("Powered: yes") >= 0
            var aliasMatch = text.match(/Alias:\s+(.+)/)
            if (aliasMatch) btAlias = aliasMatch[1].trim()
            btDiscoverable = text.indexOf("Discoverable: yes") >= 0
            btPairable = text.indexOf("Pairable: yes") >= 0
            readBtDevices.running = true
        }
    }

    Process {
        id: readBtDevices
        command: ["bluetoothctl", "devices"]
        running: false
        stdout: StdioCollector { id: btDevicesCollector; waitForEnd: true }
        onExited: {
            var text = btDevicesCollector.text.trim()
            var paired = []
            var lines = text.split("\n")
            for (var i = 0; i < lines.length; i++) {
                var m = lines[i].match(/^Device\s+([0-9A-F:]+)\s+(.+)/i)
                if (m) {
                    var addr = m[1].toUpperCase()
                    var name = m[2]
                    if (name === addr) name = null
                    paired.push({ address: addr, name: name || addr, connected: false })
                }
            }
            btDevices = paired
            readBtConnected.running = true
        }
    }

    Process {
        id: readBtConnected
        command: ["bluetoothctl", "devices", "Connected"]
        running: false
        stdout: StdioCollector { id: btConnectedCollector; waitForEnd: true }
        onExited: {
            var connectedAddrs = {}
            var lines = btConnectedCollector.text.trim().split("\n")
            for (var i = 0; i < lines.length; i++) {
                var m = lines[i].match(/^Device\s+([0-9A-F:]+)/i)
                if (m) connectedAddrs[m[1].toUpperCase()] = true
            }
            var newDevs = []
            for (var j = 0; j < btDevices.length; j++) {
                newDevs.push({
                    address: btDevices[j].address,
                    name: btDevices[j].name,
                    connected: !!connectedAddrs[btDevices[j].address]
                })
            }
            btDevices = newDevs
        }
    }

    Process {
        id: setBtPower
        command: []
        running: false
    }

    Process {
        id: setBtAlias
        command: []
        running: false
        onExited: readBtState.running = true
    }

    Process {
        id: setBtDiscoverable
        command: []
        running: false
        onExited: readBtState.running = true
    }

    Process {
        id: setBtPairable
        command: []
        running: false
        onExited: readBtState.running = true
    }

    function toggleBt() {
        if (!btOn) {
            setBtPower.command = ["sh", "-c", "bluetoothctl power on && bluetoothctl discoverable on && bluetoothctl pairable on"]
        } else {
            setBtPower.command = ["bluetoothctl", "power", "off"]
        }
        setBtPower.running = false
        setBtPower.running = true
        btOn = !btOn
        refreshRequested()
    }

    function applyAlias(name) {
        setBtAlias.command = ["bluetoothctl", "system-alias", name]
        setBtAlias.running = false
        setBtAlias.running = true
    }

    function toggleDiscoverable() {
        setBtDiscoverable.command = ["bluetoothctl", "discoverable", btDiscoverable ? "off" : "on"]
        setBtDiscoverable.running = false
        setBtDiscoverable.running = true
        btDiscoverable = !btDiscoverable
    }

    function togglePairable() {
        setBtPairable.command = ["bluetoothctl", "pairable", btPairable ? "off" : "on"]
        setBtPairable.running = false
        setBtPairable.running = true
        btPairable = !btPairable
    }

    function refresh() {
        readBtState.running = true
    }
}
