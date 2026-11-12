import QtQuick
import "../../../themes"
import "../../../components" as Components

Components.SettingsPage {
    title: "Launcher"
    icon: "\uf135"
    description: "Settings for the Phantom application launcher."

    Components.SettingsCard {
        title: "Coming with Milestone 5"

        Text {
            width: parent.width
            text: "The launcher is the next major milestone. Its size, position, search behavior and provider settings will appear here once the launcher is implemented."
            color: Theme.mutedForeground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            wrapMode: Text.WordWrap
            lineHeight: Theme.lineHeight
        }
    }
}
