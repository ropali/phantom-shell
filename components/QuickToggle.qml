import QtQuick
import QtQuick.Layouts
import "../themes"

Item {
    id: root

    property string icon: ""
    property string label: ""
    property bool active: false
    property bool isEnabled: true

    signal toggled()
    signal detailClicked()

    implicitWidth: 48
    implicitHeight: 46
    opacity: isEnabled ? 1 : 0.45

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusSmall
        color: root.active ? Theme.primary
            : toggleMouse.containsMouse && root.isEnabled ? Theme.surfaceElevated
            : Theme.surface
        border.width: root.active ? 0 : Theme.borderWidth
        border.color: Theme.border

        Behavior on color {
            ColorAnimation { duration: Theme.animationFast; easing.type: Theme.easingType }
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 2

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.icon
            color: root.active ? Theme.onPrimary : Theme.foreground
            font.family: Theme.iconFontFamily
            font.pixelSize: Theme.fontSizeSmall
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.label
            color: root.active ? Theme.onPrimary : Theme.mutedForeground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeTiny
        }
    }

    MouseArea {
        id: toggleMouse
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.isEnabled
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }

    Item {
        width: 16
        height: 16
        anchors.top: parent.top
        anchors.right: parent.right

        Text {
            anchors.centerIn: parent
            text: "\uf054"
            color: root.active ? Theme.onPrimary : Theme.mutedForeground
            opacity: 0.75
            font.family: Theme.iconFontFamily
            font.pixelSize: Theme.fontSizeTiny
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.detailClicked()
        }
    }
}
