import Quickshell
import QtQuick
import "./shared" as Pywal

Item {
    property var pywal: Pywal.Pywal { id: pywalColors }
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Text {
        anchors.centerIn: parent
        text: Qt.formatDateTime(clock.date, "hh:mm")
        color: pywalColors.color4
    }
}
