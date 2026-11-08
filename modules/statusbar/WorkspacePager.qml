import QtQuick
import "../../services" as Services
import "../../themes"

Item {
    id: root

    implicitWidth: row.implicitWidth
    implicitHeight: Theme.controlHeight - Theme.spacing.md

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Theme.spacing.xs

        Repeater {
            model: Services.Hyprland.workspaceIds()

            delegate: Item {
                id: cell
                required property int modelData

                readonly property var workspace: Services.Hyprland.workspaceById(modelData)
                readonly property bool active: workspace ? workspace.active : false

                width: active ? Theme.controlHeight - Theme.spacing.md : Theme.spacing.md + Theme.spacing.xs
                height: root.implicitHeight

                Rectangle {
                    anchors.centerIn: parent
                    width: cell.active ? Theme.controlHeight - Theme.spacing.md : Theme.spacing.sm + Theme.spacing.xs
                    height: cell.active ? Theme.controlHeight - Theme.spacing.md : width
                    radius: height / 2
                    color: cell.active ? Theme.primary
                        : cellMouse.containsMouse ? Theme.foreground
                        : Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.35)

                    Behavior on color {
                        ColorAnimation { duration: Theme.animationFast; easing.type: Theme.easingType }
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: cell.active
                        text: cell.modelData
                        color: Theme.onPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        font.weight: Theme.fontWeightBold
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
}
