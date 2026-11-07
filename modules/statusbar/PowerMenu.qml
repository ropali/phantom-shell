import QtQuick
import "../../services" as Services
import "../../components" as Components
import "../../themes"

Components.Popup {
    id: root

    popupWidth: 220
    padding: Theme.padding
    spacing: Theme.spacing.xs

    readonly property var actions: Services.Session.actions

    Repeater {
        model: root.actions

        delegate: Rectangle {
            id: actionRow
            required property var modelData

            width: root.popupWidth - root.padding * 2
            height: Theme.controlHeight
            radius: Theme.radiusSmall
            color: actionMouse.containsMouse
                ? (modelData.destructive ? Theme.surfaceElevated : Theme.surface)
                : "transparent"

            Row {
                anchors.left: parent.left
                anchors.leftMargin: Theme.spacing.md
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.spacing.md

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: actionRow.modelData.icon
                    color: actionRow.modelData.destructive ? Theme.error : Theme.mutedForeground
                    font.family: Theme.iconFontFamily
                    font.pixelSize: Theme.fontSize
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: actionRow.modelData.label
                    color: actionRow.modelData.destructive ? Theme.error : Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMedium
                }
            }

            MouseArea {
                id: actionMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.shown = false;
                    Services.Session.run(actionRow.modelData.id);
                }
            }
        }
    }
}
