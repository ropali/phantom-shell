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

        Components.AudioPanel {
            width: parent.width
        }
    }
}
