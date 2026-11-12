import QtQuick
import "../../../themes"
import "../../../components" as Components

Components.SettingsPage {
    title: "Notifications"
    icon: "\uf0f3"
    description: "Configure notification popups, history and Do Not Disturb behavior."

    Components.SettingsCard {
        title: "Coming with Milestone 5"

        Text {
            width: parent.width
            text: "The notification center, popups and history are part of Milestone 5. The shared notification service will remain the single source of truth for these settings."
            color: Theme.mutedForeground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            wrapMode: Text.WordWrap
            lineHeight: Theme.lineHeight
        }
    }
}
