import QtQuick
import "../../services" as Services
import "../../components" as Components
import "../../themes"

Item {
    id: root

    implicitWidth: Theme.buttonSize
    implicitHeight: Theme.buttonSize

    Components.IconButton {
        anchors.fill: parent
        active: popup.shown
        icon: Services.Notifications.doNotDisturb ? "\uf1f6" : "\uf0f3"
        iconColor: Services.Notifications.doNotDisturb ? Theme.mutedForeground : Theme.foreground
        tooltip: Services.Notifications.doNotDisturb ? "Do Not Disturb is on" : "Notifications"
        onClicked: {
            const wasOpen = popup.shown;
            Services.UiState.dismissAll();
            popup.shown = !wasOpen;
        }
    }

    Components.Popup {
        id: popup
        anchorItem: root
        popupWidth: 270
        padding: Theme.padding
        spacing: Theme.spacing.md

        Text {
            width: parent.width
            text: "Notifications"
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Theme.fontWeightBold
        }

        Text {
            width: parent.width
            text: "The notification center is scheduled for Milestone 4. No notification daemon is running yet."
            color: Theme.mutedForeground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            wrapMode: Text.WordWrap
            lineHeight: 1.3
        }

        Item {
            width: parent.width
            height: Theme.controlHeight

            Rectangle {
                anchors.fill: parent
                radius: Theme.radiusSmall
                color: Theme.surface
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: Theme.spacing.md
                anchors.verticalCenter: parent.verticalCenter
                text: "Do Not Disturb"
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeBase
            }

            Components.ToggleSwitch {
                anchors.right: parent.right
                anchors.rightMargin: Theme.spacing.md
                anchors.verticalCenter: parent.verticalCenter
                checked: Services.Notifications.doNotDisturb
                onToggled: Services.Notifications.toggleDnd()
            }
        }
    }
}
