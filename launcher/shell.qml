import Quickshell
import QtQuick
import QtQuick.Window
import Quickshell.Hyprland

ShellRoot {
    LauncherPanel {
        id: launcher
    }

    GlobalShortcut {
        appid: "qs-shortcuts"
        name: "app-launcher"
        description: "Toggle launcher"
        onPressed: launcher.toggle()
    }
}
