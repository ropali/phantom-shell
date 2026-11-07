import QtQuick
import Quickshell
import "../../config" as Config
import "../../services" as Services
import "../../themes"

Row {
    id: root
    spacing: Theme.spacing.sm

    function workspaceIds() {
        const workspaces = Services.Hyprland.workspaces ? Services.Hyprland.workspaces.values : [];
        const seen = ({});
        for (let i = 0; i < workspaces.length; i++) {
            const workspace = workspaces[i];
            if (workspace && workspace.id > 0)
                seen[workspace.id] = true;
        }

        const focused = Services.Hyprland.focusedWorkspace;
        if (focused && focused.id > 0)
            seen[focused.id] = true;

        const ids = Object.keys(seen).map(Number).sort((a, b) => a - b);
        if (ids.length === 0)
            ids.push(1);

        while (ids.length < Config.Settings.workspaceMinCount)
            ids.push(ids[ids.length - 1] + 1);

        return ids.slice(0, Config.Settings.workspaceMaxCount);
    }

    Repeater {
        model: root.workspaceIds()

        delegate: Item {
            id: cell
            required property int modelData

            readonly property var workspace: {
                const workspaces = Services.Hyprland.workspaces ? Services.Hyprland.workspaces.values : [];
                for (let i = 0; i < workspaces.length; i++) {
                    if (workspaces[i].id === modelData)
                        return workspaces[i];
                }
                return null;
            }
            readonly property bool active: workspace ? workspace.active : false

            width: Theme.workspaceButtonSize
            height: Theme.workspaceButtonSize

            Rectangle {
                anchors.centerIn: parent
                width: Theme.workspaceButtonSize - Theme.spacing.xs
                height: Theme.workspaceButtonSize - Theme.spacing.xs
                radius: Theme.radiusSmall
                color: cell.active ? Theme.primary
                    : cellMouse.containsMouse ? Theme.surface
                    : "transparent"

                Behavior on color {
                    ColorAnimation { duration: Theme.animationFast; easing.type: Theme.easingType }
                }

                Text {
                    anchors.centerIn: parent
                    text: cell.modelData
                    color: cell.active ? Theme.onPrimary : Theme.mutedForeground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeBase
                    font.weight: cell.active ? Theme.fontWeightBold : Theme.fontWeightMedium
                }
            }

            MouseArea {
                id: cellMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Services.Hyprland.switchTo(cell.modelData)
            }
        }
    }
}
