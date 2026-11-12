import QtQuick
import "../themes"

Item {
    id: root

    property string label: ""
    property string value: ""

    width: parent ? parent.width : 300
    height: Theme.rowHeight

    Text {
        anchors.left: parent.left
        anchors.leftMargin: Theme.spacing.sm
        anchors.verticalCenter: parent.verticalCenter
        text: root.label
        color: Theme.mutedForeground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
    }

    Text {
        anchors.right: parent.right
        anchors.rightMargin: Theme.spacing.sm
        anchors.leftMargin: Theme.spacing.xl
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(implicitWidth, parent.width - Theme.spacing.xl * 2)
        horizontalAlignment: Text.AlignRight
        text: root.value
        color: Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        elide: Text.ElideLeft
    }
}
