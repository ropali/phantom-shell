import QtQuick
import "../../../themes"
import "../../../services" as Services
import "../../../components" as Components

Flickable {
    id: root

    readonly property int preferredHeight: content.implicitHeight

    signal passwordRequired(var network)

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

        Components.NetworkPanel {
            width: parent.width
            onPasswordRequired: (network) => root.passwordRequired(network)
        }
    }
}
