import QtQuick

Item {
    id: headerRoot
    width: parent.width; height: 28

    signal closeClicked()

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
            onClicked: headerRoot.closeClicked()
        }
    }
}
