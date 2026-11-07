import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../config" as Config

PanelWindow {
    id: root

    property var modelData

    anchors.left: true
    anchors.right: true
    anchors.top: true
    anchors.bottom: true

    color: "transparent"
    aboveWindows: false
    focusable: false
    exclusiveZone: -1

    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "phantom-wallpaper"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    mask: Region {}

    Image {
        anchors.fill: parent
        source: Config.Settings.wallpaperPath.length > 0
            ? "file://" + Config.Settings.wallpaperPath
            : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
    }
}
