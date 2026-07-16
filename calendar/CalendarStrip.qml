import QtQuick
import QtQuick.LocalStorage
import "./shared" as Pywal

FocusScope {
    id: root
    property var pywal: Pywal.Pywal { id: pywalColors }

    property var markedDates: []
    property var weatherByDay: ({})
    property var events: []
    property int editingDay: -1
    property bool eventMode: false
    property bool calendarVisible: false
    property int weatherVersion: 0
    property var now: new Date()

    signal dayMarked(int day, int month, int year)
    signal dayUnmarked(int day, int month, int year)
    signal notify(string text)
    signal requestClose()

    property var notifiedAlarms: []

    function getDb() {
        return LocalStorage.openDatabaseSync("CalendarDB", "1.0", "Calendar events", 1000000)
    }

    function initDb() {
        var db = getDb()
        db.transaction(function(tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS events (id INTEGER PRIMARY KEY AUTOINCREMENT, day INTEGER, month INTEGER, year INTEGER, text TEXT, time TEXT, alarm INTEGER DEFAULT 0)")
        })
        loadEvents()
    }

    function loadEvents() {
        var db = getDb()
        db.transaction(function(tx) {
            var rs = tx.executeSql("SELECT * FROM events ORDER BY year, month, day, time")
            var arr = []
            for (var i = 0; i < rs.rows.length; i++) {
                arr.push(rs.rows[i])
            }
            root.events = arr
        })
    }

    function getEventsForDay(day, month, year) {
        var result = []
        for (var i = 0; i < root.events.length; i++) {
            var e = root.events[i]
            if (e.day === day && e.month === month && e.year === year) {
                result.push(e)
            }
        }
        return result
    }

    function eventCountForDay(day, month, year) {
        var count = 0
        for (var i = 0; i < root.events.length; i++) {
            var e = root.events[i]
            if (e.day === day && e.month === month && e.year === year) count++
        }
        return count
    }

    function addEvent(day, month, year, text, time, alarm) {
        if (!text.trim()) return
        var db = getDb()
        db.transaction(function(tx) {
            tx.executeSql("INSERT INTO events (day, month, year, text, time, alarm) VALUES (?, ?, ?, ?, ?, ?)",
                          [day, month, year, text, time, alarm ? 1 : 0])
        })
        loadEvents()
    }

    function deleteEvent(id) {
        var db = getDb()
        db.transaction(function(tx) {
            tx.executeSql("DELETE FROM events WHERE id = ?", [id])
        })
        loadEvents()
    }

    function isDateMarked(day, month, year) {
        for (var i = 0; i < markedDates.length; i++) {
            var m = markedDates[i]
            if (m.day === day && m.month === month && m.year === year) return true
        }
        return false
    }

    function generateDays() {
        var now = new Date()
        var year = now.getFullYear()
        var month = now.getMonth()
        var daysInMonth = new Date(year, month + 1, 0).getDate()
        var dayNames = ["domingo", "lunes", "martes", "miércoles", "jueves", "viernes", "sábado"]
        var model = []

        for (var i = 1; i <= daysInMonth; i++) {
            var date = new Date(year, month, i)
            model.push({
                dayName: dayNames[date.getDay()],
                dayNumber: i,
                month: month + 1,
                year: year,
                isToday: (i === now.getDate())
            })
        }

        return model
    }

    property var daysModel: generateDays()

    onCalendarVisibleChanged: {
        if (calendarVisible) {
            Qt.callLater(function() { listView.forceActiveFocus() })
        }
    }

    Component.onCompleted: {
        initDb()
        for (var i = 0; i < daysModel.length; i++) {
            if (daysModel[i].isToday) {
                listView.currentIndex = i
                listView.positionViewAtIndex(i, ListView.Contain)
                break
            }
        }
    }

    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Escape) {
            event.accepted = true
            if (root.eventMode) {
                root.eventMode = false
                listView.forceActiveFocus()
            } else {
                root.requestClose()
            }
        }
    }

    function getWeather(day) {
        var w = weatherByDay["" + day]
        if (!w) return ({ code: -1, temp: "" })
        return { code: w.code, temp: w.temp }
    }

    function selectedDayData() {
        if (listView.currentIndex < 0 || listView.currentIndex >= daysModel.length) return null
        return daysModel[listView.currentIndex]
    }

    function selectDayEvents() {
        var d = selectedDayData()
        if (!d) return []
        return getEventsForDay(d.dayNumber, d.month, d.year)
    }

    function formatDate(day, month, year) {
        var months = ["enero", "febrero", "marzo", "abril", "mayo", "junio",
                     "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"]
        var names = ["domingo", "lunes", "martes", "miércoles", "jueves", "viernes", "sábado"]
        var date = new Date(year, month - 1, day)
        return names[date.getDay()] + " " + day + " de " + months[month - 1]
    }

    Column {
        anchors.fill: parent
        spacing: 0

        ListView {
            id: listView
            width: 642
            height: root.eventMode ? 152 : parent.height
            orientation: ListView.Horizontal
            spacing: 2
            clip: true
            highlightFollowsCurrentItem: true
            preferredHighlightBegin: 0.43
            preferredHighlightEnd: 0.57
            highlightRangeMode: ListView.StrictlyEnforceRange
            snapMode: ListView.SnapOneItem
            focus: true
            cacheBuffer: 200
            anchors.horizontalCenter: parent.horizontalCenter

            model: daysModel

            delegate: Item {
                id: dayRoot
                width: 90
                height: 150

                property bool isToday: modelData.isToday
                property bool isSelected: ListView.isCurrentItem

                function weatherEmoji(code) {
                    if (code <= 0) return "\u2600\uFE0F"
                    if (code === 1) return "\uD83C\uDF24\uFE0F"
                    if (code === 2) return "\u26C5"
                    if (code <= 3) return "\u2601\uFE0F"
                    if (code <= 48) return "\uD83C\uDF2B\uFE0F"
                    if (code <= 55) return "\uD83C\uDF26\uFE0F"
                    if (code <= 57) return "\uD83C\uDF27\uFE0F"
                    if (code <= 65) return "\uD83C\uDF27\uFE0F"
                    if (code <= 67) return "\uD83C\uDF27\uFE0F"
                    if (code <= 77) return "\uD83C\uDF28\uFE0F"
                    if (code <= 82) return "\uD83C\uDF26\uFE0F"
                    if (code <= 86) return "\uD83C\uDF28\uFE0F"
                    return "\u26C8\uFE0F"
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width - 6
                    height: parent.height - 6
                    radius: 12
                    color: dayRoot.isToday ? pywalColors.color4 + "33" : (dayRoot.isSelected && !dayRoot.isToday ? "#22ffffff" : "transparent")
                    border {
                        color: dayRoot.isToday ? pywalColors.color4 + "66" : (dayRoot.isSelected && !dayRoot.isToday ? "#30ffffff" : "transparent")
                        width: 1
                    }
                    Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.OutQuad } }
                }

                Rectangle {
                    anchors { top: parent.top; topMargin: 6; horizontalCenter: parent.horizontalCenter }
                    width: 5; height: 5; radius: 2.5; color: pywalColors.color4
                    visible: root.isDateMarked(modelData.dayNumber, modelData.month, modelData.year)
                    Behavior on visible { NumberAnimation { duration: 150 } }
                }

                Rectangle {
                    anchors { top: parent.top; topMargin: 6; left: parent.left; leftMargin: 8 }
                    width: 6; height: 6; radius: 3; color: pywalColors.color5
                    property int ec: root.eventCountForDay(modelData.dayNumber, modelData.month, modelData.year)
                    visible: ec > 0
                    Text {
                        anchors.centerIn: parent
                        text: parent.ec > 9 ? "9+" : parent.ec
                        color: "#000000"; font.pixelSize: 7; font.bold: true
                    }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 3

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: modelData.dayName.substring(0, 3)
                        color: dayRoot.isToday ? pywalColors.color4 : (dayRoot.isSelected ? "#ffffff" : "#aaaaaa")
                        font.pixelSize: 11; font.bold: dayRoot.isToday
                        font.capitalization: Font.Capitalize
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: modelData.dayNumber
                        color: dayRoot.isToday ? "#000000" : (dayRoot.isSelected ? "#ffffff" : "#cccccc")
                        font.pixelSize: 18; font.bold: dayRoot.isToday || dayRoot.isSelected
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: {
                            root.weatherVersion
                            var w = root.weatherByDay["" + modelData.dayNumber]
                            return w ? dayRoot.weatherEmoji(w.code) : ""
                        }
                        color: dayRoot.isToday ? "#000000" : "#ffffff"
                        font.pixelSize: 26
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: {
                            root.weatherVersion
                            var w = root.weatherByDay["" + modelData.dayNumber]
                            return w ? w.temp : ""
                        }
                        color: dayRoot.isToday ? "#000000" : (dayRoot.isSelected ? "#ffffff" : "#bbbbbb")
                        font.pixelSize: 14; font.bold: true
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        listView.currentIndex = index
                        root.eventMode = true
                        eventInput.forceActiveFocus()
                    }
                }
            }

            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Left) {
                    event.accepted = true
                    if (currentIndex > 0) {
                        currentIndex--
                        positionViewAtIndex(currentIndex, ListView.Contain)
                    }
                } else if (event.key === Qt.Key_Right) {
                    event.accepted = true
                    if (currentIndex < count - 1) {
                        currentIndex++
                        positionViewAtIndex(currentIndex, ListView.Contain)
                    }
                } else if (event.key === Qt.Key_Space) {
                    event.accepted = true
                    root.toggleMark(currentIndex)
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_N) {
                    event.accepted = true
                    root.eventMode = true
                    eventInput.forceActiveFocus()
                }
            }
        }

        Item {
            width: parent.width
            height: root.eventMode ? parent.height - listView.height : 0
            clip: true

            Behavior on height {
                NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
            }

            Column {
                anchors.fill: parent
                spacing: 0
                visible: root.eventMode

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#25ffffff"
                }

                Item {
                    width: parent.width
                    height: parent.height - 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 4

                        Text {
                            text: {
                                var d = root.selectedDayData()
                                if (!d) return "Selecciona un d\u00EDa"
                                var dayEvents = root.selectDayEvents()
                                return "\uD83D\uDCCD " + root.formatDate(d.dayNumber, d.month, d.year) + " (" + dayEvents.length + " eventos)"
                            }
                            color: "#ffffff"
                            font.pixelSize: 11
                            font.bold: true
                            opacity: 0.8
                        }

                        Row {
                            width: parent.width
                            spacing: 4

                            Rectangle {
                                width: parent.width - 102
                                height: 24
                                radius: 8
                                color: "#18ffffff"
                                border { color: "#25ffffff"; width: 1 }

                                TextInput {
                                    id: eventInput
                                    anchors.fill: parent
                                    anchors.margins: 6
                                    color: "#ffffff"
                                    font.pixelSize: 11
                                    verticalAlignment: TextInput.AlignVCenter
                                    clip: true

                                    Text {
                                        anchors.fill: parent
                                        text: "Escribe un evento..."
                                        color: "#aaaaaa"
                                        font.pixelSize: 11
                                        visible: !parent.text
                                    }

                                    Keys.onPressed: (event) => {
                                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                            event.accepted = true
                                            saveEvent()
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                width: 36
                                height: 24
                                radius: 8
                                color: "#18ffffff"
                                border { color: "#25ffffff"; width: 1 }

                                TextInput {
                                    id: timeInput
                                    anchors.fill: parent
                                    anchors.margins: 4
                                    color: "#ffffff"
                                    font.pixelSize: 11
                                    verticalAlignment: TextInput.AlignVCenter
                                    horizontalAlignment: TextInput.AlignHCenter
                                    text: ""
                                    inputMask: "99:99"

                                    Text {
                                        anchors.centerIn: parent
                                        text: "16:00"
                                        color: "#666666"
                                        font.pixelSize: 11
                                        visible: !parent.text
                                    }
                                }
                            }

                            Rectangle {
                                id: alarmToggle
                                width: 26
                                height: 24
                                radius: 8
                                color: toggled ? pywalColors.color4 + "33" : "#18ffffff"
                                border { color: "#25ffffff"; width: 1 }

                                property bool toggled: false

                                Text {
                                    anchors.centerIn: parent
                                    text: "\uD83D\uDD14"
                                    font.pixelSize: 12
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        parent.toggled = !parent.toggled
                                    }
                                }
                            }

                            Rectangle {
                                width: 28
                                height: 24
                                radius: 8
                                color: pywalColors.color4
                                opacity: 0.7

                                Text {
                                    anchors.centerIn: parent
                                    text: "\uD83D\uDCBE"
                                    color: "#000000"
                                    font.pixelSize: 13
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: saveEvent()
                                }
                            }
                        }

                        ListView {
                            id: eventListView
                            width: parent.width
                            height: parent.height - 52
                            clip: true
                            spacing: 2

                            model: root.selectDayEvents()

                            delegate: Rectangle {
                                width: parent.width
                                height: 22
                                radius: 6
                                color: "#12ffffff"

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 4
                                    spacing: 4

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: modelData.alarm ? "\uD83D\uDD14" : "\uD83D\uDCCC"
                                        font.pixelSize: 10
                                    }

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: modelData.text
                                        color: "#ffffff"
                                        font.pixelSize: 11
                                        elide: Text.ElideRight
                                        width: parent.width - 80
                                    }

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: modelData.time || "todo el d\u00EDa"
                                        color: "#aaaaaa"
                                        font.pixelSize: 10
                                        width: 50
                                        horizontalAlignment: Text.AlignRight
                                    }

                                    Rectangle {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 16
                                        height: 16
                                        radius: 8
                                        color: "transparent"

                                        Text {
                                            anchors.centerIn: parent
                                            text: "\u2716"
                                            color: "#ff6666"
                                            font.pixelSize: 10
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: root.deleteEvent(modelData.id)
                                        }
                                    }
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "Sin eventos para este d\u00EDa"
                                color: "#666666"
                                font.pixelSize: 10
                                visible: parent.count === 0
                            }
                        }
                    }
                }
            }
        }
    }

    function saveEvent() {
        var d = selectedDayData()
        if (!d || !eventInput.text.trim()) return
        root.addEvent(d.dayNumber, d.month, d.year, eventInput.text.trim(), timeInput.text || "", alarmToggle.toggled)
        eventInput.text = ""
        timeInput.text = ""
        alarmToggle.toggled = false
    }

    function checkAlarms() {
        try {
            var now = new Date()
            var currentTime = ("0" + now.getHours()).slice(-2) + ":" + ("0" + now.getMinutes()).slice(-2)
            var currentDay = now.getDate()
            var currentMonth = now.getMonth() + 1
            var currentYear = now.getFullYear()

            var db = getDb()
            db.transaction(function(tx) {
                var rs = tx.executeSql("SELECT * FROM events WHERE alarm = 1 AND time = ? AND day = ? AND month = ? AND year = ?",
                                       [currentTime, currentDay, currentMonth, currentYear])
                for (var i = 0; i < rs.rows.length; i++) {
                    var ev = rs.rows[i]
                    if (root.notifiedAlarms.indexOf(ev.id) < 0) {
                        root.notifiedAlarms.push(ev.id)
                        root.notify(ev.text)
                    }
                }
            })
        } catch (e) {
            print("checkAlarms error: " + e)
        }
    }

    function getItemData(index) {
        if (index < 0 || index >= daysModel.length) return null
        return daysModel[index]
    }

    function toggleMark(index) {
        var item = getItemData(index)
        if (!item) return

        var marker = { day: item.dayNumber, month: item.month, year: item.year }
        var idx = -1
        for (var i = 0; i < markedDates.length; i++) {
            var m = markedDates[i]
            if (m.day === marker.day && m.month === marker.month && m.year === marker.year) {
                idx = i
                break
            }
        }

        var newMarked = markedDates.slice()
        if (idx >= 0) {
            newMarked.splice(idx, 1)
            dayUnmarked(marker.day, marker.month, marker.year)
        } else {
            newMarked.push(marker)
            dayMarked(marker.day, marker.month, marker.year)
        }
        markedDates = newMarked
    }
}
