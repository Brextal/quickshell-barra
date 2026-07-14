import Quickshell
import Quickshell.Io
import QtQuick
import "./shared" as Pywal

Column {
    id: netRoot
    width: parent.width
    spacing: 6
    property var pywal: Pywal.Pywal { id: pywalColors }

    property string connType: "none"
    property string connName: ""
    property string connDevice: ""
    property int connSignal: 0
    property var wifiNetworks: []
    property bool showNetworks: false
    property bool connecting: false
    property string connectSsid: ""
    property string connectPassword: ""

    signal refreshRequested()

    Text { width: parent.width; color: "#ffffff"; font.pixelSize: 10; text: "\uf1eb Red"; font.family: "Symbols Nerd Font" }

    Item {
        width: parent.width; height: 30
        Row {
            anchors.verticalCenter: parent.verticalCenter; spacing: 8
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: connType === "wifi"
                    ? "\uf1eb"
                    : connType === "ethernet" ? "\uf1e6" : "\uf127"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 16
                color: connType === "none" ? "#f55"
                    : connType === "wifi" && connSignal < 33 ? pywalColors.color5
                    : connType === "wifi" && connSignal < 66 ? "#ffffff"
                    : connType === "wifi" ? pywalColors.color4
                    : "#ffffff"
            }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    text: connType === "none" ? "Desconectado" : connName
                    color: connType === "none" ? "#f55" : "#ffffff"
                    font.pixelSize: 12
                }
                Text {
                    text: connType === "wifi" ? "WiFi · Señal " + connSignal + "%"
                        : connType === "ethernet" ? "Cable de red"
                        : "Sin conexión"
                    color: "#ffffff"; font.pixelSize: 10
                }
            }
        }
        Rectangle {
            anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
            width: 80; height: 22; radius: 6; color: "#1a3a2a"
            visible: connType === "wifi"
            Text {
                anchors.centerIn: parent
                text: "Desconectar"
                color: pywalColors.color4; font.pixelSize: 10
            }
            MouseArea {
                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                onClicked: disconnectWifi()
            }
        }
    }

    Rectangle {
        width: parent.width; height: 24; radius: 6; color: "#18ffffff"
        visible: connType === "wifi" || connType === "none"
        Text {
            anchors.left: parent.left; anchors.leftMargin: 8; anchors.verticalCenter: parent.verticalCenter
            text: showNetworks ? "▲ Ocultar redes" : "▼ Redes disponibles"
            color: "#ffffff"; font.pixelSize: 11
        }
        MouseArea {
            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
            onClicked: {
                showNetworks = !showNetworks
                if (showNetworks) scanWifi()
            }
        }
    }

    Item {
        width: parent.width
        height: showNetworks ? Math.min(wifiListColumn.height, 160) : 0
        clip: true
        visible: showNetworks || height > 0

        Behavior on height {
            NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
        }

        Column {
            id: wifiListColumn
            width: parent.width
            Repeater {
                model: wifiNetworks
                delegate: Item {
                    width: parent.width; height: 26
                    Rectangle {
                        anchors.fill: parent; radius: 6
                        color: ma.containsMouse ? "#18ffffff" : "transparent"
                    }
                    Row {
                        anchors.verticalCenter: parent.verticalCenter; spacing: 6
                        anchors.left: parent.left; anchors.leftMargin: 4
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.ssid || "<Red oculta>"
                            color: "#ffffff"; font.pixelSize: 11
                            elide: Text.ElideRight; width: 150
                        }
                        Item {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 40; height: 12
                            Repeater {
                                model: 4
                                Rectangle {
                                    x: index * 10; y: 6 - Math.min(index + 1, modelData.signal / 25) * 2
                                    width: 8; height: Math.min(index + 1, modelData.signal / 25) * 3
                                    radius: 2
                                    color: modelData.signal > index * 25 ? pywalColors.color4 : "#333"
                                }
                            }
                        }
                        Text {
                            text: {
                                var s = modelData.security || ""
                                if (s.indexOf("WPA3") >= 0) return "WPA3"
                                if (s.indexOf("WPA2") >= 0) return "WPA2"
                                if (s.indexOf("WPA") >= 0) return "WPA"
                                if (s.indexOf("WEP") >= 0) return "WEP"
                                return s ? "Segura" : "Abierta"
                            }
                            color: "#ffffff"; font.pixelSize: 9
                        }
                    }
                    MouseArea {
                        id: ma
                        anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            connectSsid = modelData.ssid
                            connectPassword = ""
                            showNetworks = false
                            Qt.callLater(() => pwInput.forceActiveFocus())
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        width: parent.width; height: connectSsid ? 56 : 0
        radius: 8; color: "#22ffffff"; clip: true
        visible: connectSsid !== ""
        onVisibleChanged: if (visible) Qt.callLater(() => pwInput.forceActiveFocus())
        Behavior on height { NumberAnimation { duration: 150 } }

        Column {
            anchors.fill: parent; anchors.margins: 6; spacing: 4
            visible: connectSsid !== ""
            Text {
                text: "Conectar a: " + connectSsid
                color: "#ffffff"; font.pixelSize: 11
            }
            Row {
                spacing: 6
                Rectangle {
                    width: 160; height: 26; radius: 6; color: "#18ffffff"
                    border { color: "#30ffffff"; width: 1 }
                    TextInput {
                        id: pwInput
                        anchors.fill: parent; anchors.margins: 4
                        color: "#ffffff"; font.pixelSize: 11
                    }
                    Text {
                        anchors.fill: parent; anchors.margins: 4
                        text: "Contraseña"
                        color: "#ffffff"; font.pixelSize: 11
                        visible: pwInput.text.length === 0 && !pwInput.activeFocus
                    }
                }
                Rectangle {
                    width: 60; height: 26; radius: 6
                    color: connecting ? "#3a3a3a" : pywalColors.color4
                    opacity: connecting ? 0.5 : 1
                    Text {
                        anchors.centerIn: parent
                        text: connecting ? "..." : "Conectar"
                        color: "white"; font { pixelSize: 11; bold: true }
                    }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        enabled: !connecting && connectPassword.length > 0
                        onClicked: connectToWifi(connectSsid, connectPassword)
                    }
                }
                Rectangle {
                    width: 40; height: 26; radius: 6; color: "transparent"
                    Text { anchors.centerIn: parent; text: "✕"; color: "#ffffff"; font.pixelSize: 11 }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: { connectSsid = ""; connectPassword = "" }
                    }
                }
            }
        }
    }

    Process {
        id: readNetState
        command: ["nmcli", "-t", "-f", "TYPE,DEVICE,STATE,CONNECTION", "device", "status"]
        running: false
        stdout: StdioCollector { id: netCollector; waitForEnd: true }
        onExited: {
            var lines = netCollector.text.trim().split("\n")
            connType = "none"
            connName = ""
            connDevice = ""
            connSignal = 0
            for (var i = 0; i < lines.length; i++) {
                var parts = lines[i].split(":")
                if (parts.length >= 4 && parts[2] === "connected") {
                    if (parts[0] === "wifi") {
                        connType = "wifi"
                        connDevice = parts[1]
                        connName = parts[3]
                        readWifiSignal.running = true
                    } else if (parts[0] === "ethernet") {
                        connType = "ethernet"
                        connDevice = parts[1]
                        connName = parts[3]
                    }
                }
            }
        }
    }

    Process {
        id: readWifiSignal
        command: ["nmcli", "-t", "-f", "SSID,SIGNAL", "device", "wifi", "list", "--rescan", "no"]
        running: false
        stdout: StdioCollector { id: wifiSigCollector; waitForEnd: true }
        onExited: {
            var lines = wifiSigCollector.text.trim().split("\n")
            var bestSignal = 0
            for (var i = 0; i < lines.length; i++) {
                var parts = lines[i].split(":")
                if (parts.length >= 2) {
                    var sig = parseInt(parts[1]) || 0
                    if (sig > bestSignal) bestSignal = sig
                }
            }
            connSignal = bestSignal
        }
    }

    Process {
        id: scanWifiCmd
        command: ["nmcli", "-t", "-f", "SSID,SIGNAL,SECURITY", "device", "wifi", "list"]
        running: false
        stdout: StdioCollector { id: wifiScanCollector; waitForEnd: true }
        onExited: {
            var lines = wifiScanCollector.text.trim().split("\n")
            var list = []
            var seen = {}
            for (var i = 0; i < lines.length; i++) {
                var parts = lines[i].split(":")
                if (parts.length >= 2) {
                    var ssid = parts[0]
                    var signal = parseInt(parts[1]) || 0
                    var security = parts.slice(2).join(":") || ""
                    if (ssid && !seen[ssid]) {
                        seen[ssid] = true
                        list.push({ ssid: ssid, signal: signal, security: security })
                    }
                }
            }
            list.sort(function(a, b) { return b.signal - a.signal })
            wifiNetworks = list
        }
    }

    function scanWifi() {
        scanWifiCmd.running = true
    }

    Process {
        id: connectWifi
        command: []
        running: false
        stdout: StdioCollector { id: wifiConnCollector; waitForEnd: true }
        onExited: {
            connecting = false
            showNetworks = false
            connectSsid = ""
            connectPassword = ""
            refreshRequested()
        }
    }

    function connectToWifi(ssid, password) {
        connecting = true
        connectWifi.command = ["nmcli", "device", "wifi", "connect", ssid, "password", password]
        connectWifi.running = false
        connectWifi.running = true
    }

    Process {
        id: disconnectNet
        command: []
        running: false
        onExited: {
            refreshRequested()
        }
    }

    function disconnectWifi() {
        disconnectNet.command = ["nmcli", "device", "disconnect", connDevice]
        disconnectNet.running = false
        disconnectNet.running = true
    }

    function refresh() {
        readNetState.running = true
    }
}
