import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "./shared" as Pywal

RowLayout {
    spacing: 4
    property var pywal: Pywal.Pywal { id: pywalColors }

    Repeater {
        model: 9
        delegate: Text {
            property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
            text: index + 1
            color: isActive ? pywalColors.color4 : "#f522c5"
        }
    }
}
