import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../config" as Config
import "../../themes"
import "../../services" as Services

PanelWindow {
    id: root

    property var modelData

    anchors.top: Config.Settings.barPosition !== "bottom"
    anchors.bottom: Config.Settings.barPosition === "bottom"
    anchors.left: true
    anchors.right: true

    margins.top: Config.Settings.barPosition === "bottom" ? 0 : Config.Settings.screenMargin
    margins.bottom: Config.Settings.barPosition === "bottom" ? Config.Settings.screenMargin : 0
    margins.left: 0
    margins.right: 0

    implicitHeight: Config.Settings.barHeight + Config.Settings.screenMargin

    readonly property int compositorGap: Config.Settings.barPosition === "bottom"
        ? Services.Hyprland.gapsOutBottom
        : Services.Hyprland.gapsOutTop

    exclusiveZone: Math.max(0,
        Config.Settings.barHeight + Config.Settings.barWindowGap
        - compositorGap - Theme.borderWidth)
    color: "transparent"
    aboveWindows: true
    focusable: false

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "phantom-bar"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    mask: barLayoutLoader.item ? barLayoutLoader.item.maskRegion : null

    Item {
        id: host
        width: root.width
        height: root.height

        BarController {
            id: barController
            screenInfo: root.screen
        }

        Loader {
            id: barLayoutLoader
            anchors.fill: parent
            sourceComponent: Config.Settings.barStyle === "pills"
                ? pillsComponent : classicComponent
            onLoaded: Qt.callLater(barController.reanchorControlCenter)
        }
    }

    Connections {
        target: Config.Settings
        function onBarStyleChanged() {
            Qt.callLater(barController.reanchorControlCenter);
        }
    }

    Component {
        id: classicComponent
        BarLayoutClassic {
            controller: barController
        }
    }

    Component {
        id: pillsComponent
        BarLayoutPills {
            controller: barController
        }
    }
}
