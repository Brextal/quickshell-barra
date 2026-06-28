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

    // ─── State ───

    property real volumeValue: 1
    property bool volumeMuted: false

    property real brightnessValue: 1
    property bool hasDdcutil: false
    property bool hasBrightness: false

    property string connType: "none"
    property string connName: ""
    property int connSignal: 0
    property var wifiNetworks: []
    property bool showNetworks: false
    property bool connecting: false
    property string connectSsid: ""
    property string connectPassword: ""

    property bool btOn: false
    property var btDevices: []

    // ─── Background ───

    Rectangle {
        id: bg
        anchors.fill: parent
        color: "#cc1a1b26"
        radius: 14
        topLeftRadius: 0
        topRightRadius: 0
        border { color: "#2a2a3a"; width: 1 }
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

                // ─── Header ───
                Item {
                    width: parent.width; height: 28
                    Text {
                        anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                        text: "Control Center"
                        color: "#f5e2c5"
                        font { pixelSize: 14; bold: true }
                    }
                    Rectangle {
                        anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                        width: 22; height: 22; radius: 6; color: "#2a2a3a"
                        Text { anchors.centerIn: parent; text: "✕"; color: "#aaaaaa"; font.pixelSize: 12 }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: root.visible = false
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: "#2a2a3a" }

                // ─── Volume ───
                Text { width: parent.width; color: "#888"; font.pixelSize: 10; text: " 🔊 Volumen" }

                Row {
                    width: parent.width; height: 34; spacing: 8
                    Item { width: 22; height: 22; anchors.verticalCenter: parent.verticalCenter
                        Text { anchors.centerIn: parent; text: root.volumeMuted ? "🔇" : "🔊"; font.pixelSize: 14 } }
                    Item {
                        width: parent.width - 22 - 30 - 36 - 24; height: parent.height
                        anchors.verticalCenter: parent.verticalCenter
                        Slider {
                            id: volumeSlider
                            anchors.centerIn: parent
                            from: 0; to: 1; value: root.volumeValue
                            implicitWidth: parent.width; implicitHeight: 20
                            onMoved: { root.volumeValue = value; applyVolume(value, root.volumeMuted) }
                            background: Rectangle {
                                x: volumeSlider.leftPadding
                                y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                                width: volumeSlider.availableWidth; height: 4; radius: 2; color: "#2a2a3a"
                                Rectangle {
                                    width: volumeSlider.visualPosition * parent.width; height: parent.height
                                    radius: 2; color: "#3dd1b0"
                                }
                            }
                            handle: Rectangle {
                                x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                                y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                                width: 14; height: 14; radius: 7; color: "#f5e2c5"
                            }
                        }
                    }
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 30; height: 22; radius: 6
                        color: root.volumeMuted ? "#4a3a3a" : "#1a3a2a"
                        Text {
                            anchors.centerIn: parent
                            text: root.volumeMuted ? "M" : "S"
                            color: root.volumeMuted ? "#f55" : "#3dd1b0"
                            font { pixelSize: 11; bold: true }
                        }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: { root.volumeMuted = !root.volumeMuted; applyVolume(root.volumeValue, root.volumeMuted) }
                        }
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 36; text: Math.round(root.volumeValue * 100) + "%"
                        color: "#aaaaaa"; font.pixelSize: 11; horizontalAlignment: Text.AlignRight
                    }
                }

                Rectangle { width: parent.width; height: 1; color: "#2a2a3a" }

                // ─── Brightness ───
                Text { width: parent.width; color: "#888"; font.pixelSize: 10; text: " ☀️ Brillo" }

                Row {
                    width: parent.width; height: 34; spacing: 8
                    Item { width: 22; height: 22; anchors.verticalCenter: parent.verticalCenter
                        Text { anchors.centerIn: parent; text: "☀️"; font.pixelSize: 13 } }
                    Item {
                        width: parent.width - 22 - 36 - 16; height: parent.height
                        anchors.verticalCenter: parent.verticalCenter
                            Slider {
                            id: brightnessSlider
                            anchors.centerIn: parent
                            from: 0.1; to: 1; value: root.brightnessValue
                            implicitWidth: parent.width; implicitHeight: 20
                            enabled: root.hasDdcutil || root.hasBrightness
                            onMoved: { root.brightnessValue = value; applyBrightness(value) }
                            background: Rectangle {
                                x: brightnessSlider.leftPadding
                                y: brightnessSlider.topPadding + brightnessSlider.availableHeight / 2 - height / 2
                                width: brightnessSlider.availableWidth; height: 4; radius: 2; color: "#2a2a3a"
                                Rectangle {
                                    width: brightnessSlider.visualPosition * parent.width; height: parent.height
                                    radius: 2; color: "#e5b83d"
                                }
                            }
                            handle: Rectangle {
                                x: brightnessSlider.leftPadding + brightnessSlider.visualPosition * (brightnessSlider.availableWidth - width)
                                y: brightnessSlider.topPadding + brightnessSlider.availableHeight / 2 - height / 2
                                width: 14; height: 14; radius: 7; color: "#f5e2c5"
                            }
                        }
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                    width: 36; text: (root.hasDdcutil || root.hasBrightness) ? Math.round(root.brightnessValue * 100) + "%" : "—"
                    color: "#aaaaaa"; font.pixelSize: 11; horizontalAlignment: Text.AlignRight
                    }
                }

                Text {
                    visible: !root.hasDdcutil && !root.hasBrightness
                    text: "⚠️ Instala 'brightnessctl' o 'ddcutil' para controlar brillo"
                    color: "#888"; font.pixelSize: 9; wrapMode: Text.WordWrap; width: parent.width
                }

                Rectangle { width: parent.width; height: 1; color: "#2a2a3a" }

                // ─── Network ───
                Text { width: parent.width; color: "#888"; font.pixelSize: 10; text: " 🌐 Red" }

                Item {
                    width: parent.width; height: 30
                    Row {
                        anchors.verticalCenter: parent.verticalCenter; spacing: 8
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.connType === "wifi" ? "📶" : root.connType === "ethernet" ? "🔌" : "⚠️"
                            font.pixelSize: 16
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                text: root.connType === "none" ? "Desconectado" : root.connName
                                color: root.connType === "none" ? "#f55" : "#f5e2c5"
                                font.pixelSize: 12
                            }
                            Text {
                                text: root.connType === "wifi" ? "WiFi · Señal " + root.connSignal + "%"
                                    : root.connType === "ethernet" ? "Cable de red"
                                    : "Sin conexión"
                                color: "#888"; font.pixelSize: 10
                            }
                        }
                    }
                }

                Rectangle {
                    width: parent.width; height: 24; radius: 6; color: "#1a1a2a"
                    visible: root.connType === "wifi" || root.connType === "none"
                    Text {
                        anchors.left: parent.left; anchors.leftMargin: 8; anchors.verticalCenter: parent.verticalCenter
                        text: root.showNetworks ? "▲ Ocultar redes" : "▼ Redes disponibles"
                        color: "#aaaaaa"; font.pixelSize: 11
                    }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.showNetworks = !root.showNetworks
                            if (root.showNetworks) root.scanWifi()
                        }
                    }
                }

                Item {
                    width: parent.width
                    height: root.showNetworks ? Math.min(wifiListColumn.height, 160) : 0
                    clip: true
                    visible: root.showNetworks || height > 0

                    Behavior on height {
                        NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
                    }

                    Column {
                        id: wifiListColumn
                        width: parent.width
                        Repeater {
                            model: root.wifiNetworks
                            delegate: Item {
                                width: parent.width; height: 26
                                Rectangle {
                                    anchors.fill: parent; radius: 6
                                    color: ma.containsMouse ? "#2a2a3a" : "transparent"
                                }
                                Row {
                                    anchors.verticalCenter: parent.verticalCenter; spacing: 6
                                    anchors.left: parent.left; anchors.leftMargin: 4
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: modelData.ssid || "<Red oculta>"
                                        color: "#f5e2c5"; font.pixelSize: 11
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
                                                color: modelData.signal > index * 25 ? "#3dd1b0" : "#333"
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
                                        color: "#808080"; font.pixelSize: 9
                                    }
                                }
                                MouseArea {
                                    id: ma
                                    anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        root.connectSsid = modelData.ssid
                                        root.connectPassword = ""
                                        root.showNetworks = false
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    width: parent.width; height: root.connectSsid ? 56 : 0
                    radius: 8; color: "#1a1a2a"; clip: true
                    visible: root.connectSsid !== ""
                    Behavior on height { NumberAnimation { duration: 150 } }

                    Column {
                        anchors.fill: parent; anchors.margins: 6; spacing: 4
                        visible: root.connectSsid !== ""
                        Text {
                            text: "Conectar a: " + root.connectSsid
                            color: "#f5e2c5"; font.pixelSize: 11
                        }
                        Row {
                            spacing: 6
                            Rectangle {
                                width: 160; height: 26; radius: 6; color: "#0a0a1a"
                                border { color: "#3a3a4a"; width: 1 }
                                TextField {
                                    id: pwInput
                                    anchors.fill: parent; anchors.margins: 4
                                    color: "#f5e2c5"; font.pixelSize: 11
                                    echoMode: TextInput.Password
                                    placeholderText: "Contraseña"
                                    background: null
                                    onTextChanged: root.connectPassword = text
                                }
                            }
                            Rectangle {
                                width: 60; height: 26; radius: 6
                                color: root.connecting ? "#3a3a3a" : "#3dd1b0"
                                opacity: root.connecting ? 0.5 : 1
                                Text {
                                    anchors.centerIn: parent
                                    text: root.connecting ? "..." : "Conectar"
                                    color: "white"; font { pixelSize: 11; bold: true }
                                }
                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    enabled: !root.connecting && root.connectPassword.length > 0
                                    onClicked: root.connectToWifi(root.connectSsid, root.connectPassword)
                                }
                            }
                            Rectangle {
                                width: 40; height: 26; radius: 6; color: "#3a3a3a"
                                Text { anchors.centerIn: parent; text: "✕"; color: "#aaaaaa"; font.pixelSize: 11 }
                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: { root.connectSsid = ""; root.connectPassword = "" }
                                }
                            }
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: "#2a2a3a" }

                // ─── Bluetooth ───
                Text { width: parent.width; color: "#888"; font.pixelSize: 10; text: " 🔷 Bluetooth" }

                Item {
                    width: parent.width; height: 28
                    Row {
                        anchors.verticalCenter: parent.verticalCenter; spacing: 8
                        Text { anchors.verticalCenter: parent.verticalCenter; text: "🔷"; font.pixelSize: 14 }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.btOn ? "Encendido" : "Apagado"
                            color: root.btOn ? "#3dd1b0" : "#f55"
                            font.pixelSize: 12
                        }
                    }
                    Rectangle {
                        anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                        width: 36; height: 20; radius: 10
                        color: root.btOn ? "#3dd1b0" : "#3a3a3a"
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Rectangle {
                            x: root.btOn ? parent.width - width - 2 : 2
                            anchors.verticalCenter: parent.verticalCenter
                            width: 16; height: 16; radius: 8; color: "white"
                            Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                        }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: root.toggleBt()
                        }
                    }
                }

                Item {
                    width: parent.width
                    height: root.btOn ? Math.min(btList.height, 100) : 0
                    clip: true
                    Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }

                    Column {
                        id: btList
                        width: parent.width
                        Repeater {
                            model: root.btDevices
                            delegate: Item {
                                width: parent.width; height: 24
                                Row {
                                    anchors.verticalCenter: parent.verticalCenter; spacing: 6
                                    anchors.left: parent.left; anchors.leftMargin: 8
                                    Text {
                                        text: "●"; font.pixelSize: 8
                                        anchors.verticalCenter: parent.verticalCenter
                                        color: modelData.connected ? "#3dd1b0" : "#555"
                                    }
                                    Text {
                                        text: modelData.name || modelData.address
                                        color: "#f5e2c5"; font.pixelSize: 11
                                        width: 160; elide: Text.ElideRight
                                    }
                                    Text {
                                        text: modelData.connected ? "Conectado" : "No conect."
                                        color: modelData.connected ? "#3dd1b0" : "#888"
                                        font.pixelSize: 10
                                    }
                                }
                            }
                        }
                        Text {
                            visible: root.btDevices.length === 0
                            text: "Sin dispositivos emparejados"
                            color: "#666"; font.pixelSize: 10; leftPadding: 8
                        }
                    }
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
        readVolume.running = true
        if (root.hasDdcutil) readBrightness.running = true
        if (root.hasBrightness) readBrightnessctl.running = true
        readNetState.running = true
        readBtState.running = true
    }

    // ─── Volume ───

    Process {
        id: readVolume
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        running: false
        stdout: StdioCollector { id: volCollector; waitForEnd: true }
        onExited: {
            var out = volCollector.text.trim()
            var match = out.match(/Volume:\s+([\d.]+)/)
            if (match) root.volumeValue = parseFloat(match[1])
            root.volumeMuted = out.indexOf("[MUTED]") >= 0
        }
    }

    Process {
        id: setVolume
        command: []
        running: false
    }

    function applyVolume(val, muted) {
        if (muted) {
            setVolume.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "1"]
        } else {
            setVolume.command = ["sh", "-c", "wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 && wpctl set-volume @DEFAULT_AUDIO_SINK@ " + val]
        }
        setVolume.running = false
        setVolume.running = true
    }

    // ─── Brightness ───

    Process {
        id: checkDdcutil
        command: ["which", "ddcutil"]
        running: true
        stdout: StdioCollector { id: ddcCheck; waitForEnd: true }
        onExited: {
            root.hasDdcutil = ddcCheck.text.trim().length > 0
            if (root.hasDdcutil) readBrightness.running = true
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
            if (match) root.brightnessValue = parseInt(match[1]) / 100
        }
    }

    Process {
        id: setBrightness
        command: []
        running: false
    }

    function applyBrightness(val) {
        if (root.hasDdcutil) {
            setBrightness.command = ["ddcutil", "setvcp", "10", String(Math.round(val * 100))]
            setBrightness.running = false
            setBrightness.running = true
        } else if (root.hasBrightness) {
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
            root.hasBrightness = brCheck.text.trim().length > 0
            if (root.hasBrightness) readBrightnessctl.running = true
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
            if (!isNaN(val)) root.brightnessValue = val / 100
        }
    }

    Process {
        id: setBrightnessctl
        command: []
        running: false
    }

    // ─── Network ───

    Process {
        id: readNetState
        command: ["nmcli", "-t", "-f", "TYPE,DEVICE,STATE", "device", "status"]
        running: false
        stdout: StdioCollector { id: netCollector; waitForEnd: true }
        onExited: {
            var lines = netCollector.text.trim().split("\n")
            root.connType = "none"
            root.connName = ""
            root.connSignal = 0
            for (var i = 0; i < lines.length; i++) {
                var parts = lines[i].split(":")
                if (parts.length >= 3 && parts[2] === "connected") {
                    if (parts[0] === "wifi") {
                        root.connType = "wifi"
                        root.connName = parts[1]
                        readWifiSignal.running = true
                    } else if (parts[0] === "ethernet") {
                        root.connType = "ethernet"
                        root.connName = parts[1]
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
            root.connSignal = bestSignal
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
            root.wifiNetworks = list
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
            root.connecting = false
            root.showNetworks = false
            root.connectSsid = ""
            root.connectPassword = ""
            delayedRefresh.restart()
        }
    }

    function connectToWifi(ssid, password) {
        root.connecting = true
        connectWifi.command = ["nmcli", "device", "wifi", "connect", ssid, "password", password]
        connectWifi.running = false
        connectWifi.running = true
    }

    // ─── Bluetooth ───

    Process {
        id: readBtState
        command: ["bluetoothctl", "show"]
        running: false
        stdout: StdioCollector { id: btCollector; waitForEnd: true }
        onExited: {
            var text = btCollector.text
            root.btOn = text.indexOf("Powered: yes") >= 0
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
            root.btDevices = paired
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
            var devs = root.btDevices
            for (var j = 0; j < devs.length; j++) {
                devs[j].connected = !!connectedAddrs[devs[j].address]
            }
            root.btDevices = devs
        }
    }

    Process {
        id: setBtPower
        command: []
        running: false
    }

    function toggleBt() {
        setBtPower.command = ["bluetoothctl", "power", root.btOn ? "off" : "on"]
        setBtPower.running = false
        setBtPower.running = true
        root.btOn = !root.btOn
        delayedRefresh.restart()
    }
}
