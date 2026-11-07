import QtQuick
import "../../../themes"
import "../../../components" as Components

Flickable {
    id: root

    readonly property int preferredHeight: content.implicitHeight

    anchors.fill: parent
    contentWidth: width
    contentHeight: content.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    interactive: contentHeight > height

    Column {
        id: content
        width: root.width
        spacing: Theme.spacing.md

        Components.ThemePicker {
            width: parent.width
        }

        Text {
            width: parent.width
            text: "Add custom themes to themes/custom/*.json"
            color: Theme.mutedForeground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            wrapMode: Text.WordWrap
        }
    }
}
