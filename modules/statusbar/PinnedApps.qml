import QtQuick
import Quickshell
import "../../config" as Config
import "../../themes"
import "../../components" as Components

Row {
    id: root

    spacing: Theme.spacing.xs

    function colorFor(key) {
        if (key === "warning") return Theme.warning;
        if (key === "success") return Theme.success;
        if (key === "info") return Theme.info;
        if (key === "secondary") return Theme.secondary;
        if (key === "tertiary") return Theme.tertiary;
        return Theme.mutedForeground;
    }

    Repeater {
        model: Config.Settings.pinnedApps

        delegate: Item {
            id: appSlot
            required property var modelData

            width: appButton.implicitWidth
            height: appButton.implicitHeight

            Components.IconButton {
                id: appButton
                anchors.fill: parent
                buttonSize: Theme.controlHeight - Theme.spacing.md
                iconSize: Theme.fontSize
                icon: appSlot.modelData.icon
                iconColor: root.colorFor(appSlot.modelData.color)
                tooltip: appSlot.modelData.label
                onClicked: Quickshell.execDetached(["sh", "-c", appSlot.modelData.command])
            }
        }
    }
}
