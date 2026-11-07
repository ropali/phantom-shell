import QtQuick
import "../themes"

Item {
    id: root

    property string icon: ""
    property string text: ""
    property bool active: false

    signal clicked()

    implicitWidth: row.implicitWidth + Theme.spacing.md
    implicitHeight: 26
    opacity: 1

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusSmall
        color: chipMouse.containsMouse ? Theme.surfaceElevated : Theme.surface
        border.width: root.active ? Theme.borderWidth : 0
        border.color: Theme.primary
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Theme.spacing.xs

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.icon
            color: root.active ? Theme.primary : Theme.mutedForeground
            font.family: Theme.iconFontFamily
            font.pixelSize: Theme.fontSizeTiny
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.text
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeTiny
        }
    }

    MouseArea {
        id: chipMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
