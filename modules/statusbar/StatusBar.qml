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

    mask: Region {
        item: bar
    }

    function updateGroupParent() {
        const slot = Config.Settings.barControlCenterPosition === "left"
            ? leftSection.groupSlot : rightSection.groupSlot;
        controlCenterGroup.parent = slot;
        Qt.callLater(barController.reanchorControlCenter);
    }

    Connections {
        target: Config.Settings
        function onBarControlCenterPositionChanged() {
            updateGroupParent();
        }
    }

    Component.onCompleted: updateGroupParent()

    readonly property int barWidth: Math.max(200, Math.min(
        Math.round(root.width * Math.max(1, Math.min(100, Config.Settings.barWidthPercent)) / 100),
        root.width - 2 * Config.Settings.edgeGap))

    Rectangle {
        id: bar

        width: root.barWidth
        height: Config.Settings.barHeight
        x: (root.width - width) / 2
        y: Config.Settings.barPosition === "bottom" ? root.height - height : 0
        radius: Theme.radius
        color: Theme.barBackground
        border.width: Theme.borderWidth
        border.color: Theme.border
        clip: true

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onClicked: Services.UiState.dismissAll()
        }

        Item {
            id: networkAnchor
            opacity: 0
            width: 0
            height: 0
        }

        Item {
            id: bluetoothAnchor
            opacity: 0
            width: 0
            height: 0
        }

        Item {
            id: audioAnchor
            opacity: 0
            width: 0
            height: 0
        }

        Item {
            id: powerAnchor
            opacity: 0
            width: 0
            height: 0
        }

        Item {
            id: controlCenterAnchor
            opacity: 0
            width: 0
            height: 0
        }

        BarController {
            id: barController
            screenInfo: root.screen
            networkAnchor: networkAnchor
            bluetoothAnchor: bluetoothAnchor
            audioAnchor: audioAnchor
            powerAnchor: powerAnchor
            controlCenterAnchor: controlCenterAnchor
        }

        LeftSection {
            id: leftSection
            controller: barController
            anchors.left: parent.left
            anchors.leftMargin: Theme.spacing.lg
            anchors.verticalCenter: parent.verticalCenter
        }

        CenterSection {
            anchors.centerIn: parent
        }

        RightSection {
            id: rightSection
            controller: barController
            anchors.right: parent.right
            anchors.rightMargin: Theme.spacing.lg
            anchors.verticalCenter: parent.verticalCenter
        }

        ControlCenterGroup {
            id: controlCenterGroup
            controller: barController
        }
    }
}
