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

    function scalingMode() {
        if (Config.Settings.wallpaperScaling === "fit")
            return Image.PreserveAspectFit;
        if (Config.Settings.wallpaperScaling === "stretch")
            return Image.Stretch;
        if (Config.Settings.wallpaperScaling === "center")
            return Image.Pad;
        return Image.PreserveAspectCrop;
    }

    Image {
        anchors.fill: parent
        source: Config.Settings.wallpaperPath.length > 0
            ? "file://" + Config.Settings.wallpaperPath
            : ""
        fillMode: root.scalingMode()
        asynchronous: true
        cache: false
        opacity: status === Image.Ready ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Config.Settings.animationsEnabled
                    ? Config.Settings.wallpaperTransition : 0
            }
        }
    }
}
