import QtQuick
import "../../themes"
import "../../components" as Components

Components.Popup {
    id: root

    popupWidth: 320
    padding: Theme.padding
    spacing: Theme.spacing.md

    Text {
        width: parent.width
        text: "Audio"
        color: Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.weight: Theme.fontWeightBold
    }

    Components.AudioPanel {
        width: parent.width
    }
}
