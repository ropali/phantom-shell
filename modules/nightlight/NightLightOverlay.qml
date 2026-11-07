import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../services" as Services

PanelWindow {
    id: root

    property var modelData

    screen: modelData
    visible: Services.NightLight.enabled

    anchors.left: true
    anchors.right: true
    anchors.top: true
    anchors.bottom: true

    color: "transparent"
    aboveWindows: true
    focusable: false
    exclusiveZone: -1

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "phantom-night-light"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    mask: Region {}

    Rectangle {
        anchors.fill: parent
        color: "#ffb36b"
        opacity: Services.NightLight.opacity
    }
}
