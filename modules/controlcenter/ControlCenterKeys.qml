import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../services" as Services

PanelWindow {
    id: root

    screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
    visible: Services.UiState.detailOpen

    anchors.left: true
    anchors.right: true
    anchors.top: true
    anchors.bottom: true

    color: "transparent"
    aboveWindows: true
    focusable: true
    exclusiveZone: -1

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "phantom-control-center-keys"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    mask: Region {}

    Item {
        anchors.fill: parent
        focus: true

        Component.onCompleted: forceActiveFocus()

        Keys.onEscapePressed: Services.UiState.closeDetail()
    }
}
