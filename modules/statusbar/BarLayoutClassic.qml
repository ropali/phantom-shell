import QtQuick
import Quickshell
import "../../config" as Config
import "../../themes"
import "../../services" as Services

Item {
    id: root

    property var controller: null

    width: parent ? parent.width : 0
    height: parent ? parent.height : Config.Settings.barHeight + Config.Settings.screenMargin

    readonly property Region maskRegion: Region {
        item: bar
    }

    readonly property int barWidth: Math.max(200, Math.min(
        Math.round(width * Math.max(1, Math.min(100, Config.Settings.barWidthPercent)) / 100),
        width - 2 * Config.Settings.edgeGap))

    function updateGroupParent() {
        if (!root.controller || !leftSection || !rightSection || !controlCenterGroup)
            return;
        const slot = Config.Settings.barControlCenterPosition === "left"
            ? leftSection.groupSlot : rightSection.groupSlot;
        controlCenterGroup.parent = slot;
        Qt.callLater(root.controller.reanchorControlCenter);
    }

    Connections {
        target: Config.Settings
        function onBarControlCenterPositionChanged() {
            root.updateGroupParent();
        }
    }

    Component.onCompleted: updateGroupParent()

    Rectangle {
        id: bar

        width: root.barWidth
        height: Config.Settings.barHeight
        x: Config.Settings.barAlignment === "left"
            ? Math.max(0, Math.min(root.width - width, Config.Settings.edgeGap))
            : Config.Settings.barAlignment === "right"
                ? root.width - width - Math.max(0, Math.min(root.width - width, Config.Settings.edgeGap))
                : (root.width - width) / 2
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

        LeftSection {
            id: leftSection
            controller: root.controller
            anchors.left: parent.left
            anchors.leftMargin: Theme.spacing.lg
            anchors.verticalCenter: parent.verticalCenter
        }

        CenterSection {
            anchors.centerIn: parent
        }

        RightSection {
            id: rightSection
            controller: root.controller
            anchors.right: parent.right
            anchors.rightMargin: Theme.spacing.lg
            anchors.verticalCenter: parent.verticalCenter
        }

        ControlCenterGroup {
            id: controlCenterGroup
            controller: root.controller
        }
    }
}
