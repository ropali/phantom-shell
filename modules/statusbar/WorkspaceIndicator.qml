import QtQuick
import "../../services" as Services
import "../../themes"

Row {
    id: root
    spacing: Theme.spacing.sm

    Repeater {
        model: Services.Hyprland.workspaceIds()

        delegate: Item {
            id: cell
            required property int modelData

            readonly property var workspace: Services.Hyprland.workspaceById(modelData)
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
