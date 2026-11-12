import QtQuick
import "../themes"

Rectangle {
    id: root

    property string text: ""
    property string icon: ""
    property bool destructive: false
    property bool isEnabled: true
    signal clicked()

    implicitWidth: buttonRow.implicitWidth + Theme.spacing.lg * 2
    implicitHeight: 32
    width: implicitWidth
    height: implicitHeight
    radius: Theme.radiusSmall
    opacity: isEnabled ? 1 : 0.45
    color: mouseArea.containsMouse && isEnabled
        ? (destructive ? Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.16)
            : Qt.rgba(Theme.surfaceElevated.r, Theme.surfaceElevated.g, Theme.surfaceElevated.b, 0.9))
        : Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.7)
    border.width: Theme.borderWidth
    border.color: destructive
        ? Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.45)
        : mouseArea.containsMouse ? Theme.accentBorder : Theme.subtleBorder
    scale: mouseArea.pressed ? 0.97 : 1.0

    Behavior on color {
        ColorAnimation { duration: Theme.animationFast; easing.type: Theme.easingType }
    }

    Behavior on border.color {
        ColorAnimation { duration: Theme.animationFast }
    }

    Behavior on scale {
        NumberAnimation { duration: Theme.animationFast; easing.type: Easing.OutCubic }
    }

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        opacity: mouseArea.containsMouse && !root.destructive ? 1.0 : 0.0
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                position: 0.0
                color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12)
            }
            GradientStop { position: 1.0; color: "transparent" }
        }

        Behavior on opacity {
            NumberAnimation { duration: Theme.animationFast }
        }
    }

    Row {
        id: buttonRow
        anchors.centerIn: parent
        spacing: Theme.spacing.xs

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.icon.length > 0
            text: root.icon
            color: root.destructive ? Theme.error : Theme.primary
            font.family: Theme.iconFontFamily
            font.pixelSize: Theme.fontSizeSmall
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.text
            color: root.destructive ? Theme.error : Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Theme.fontWeightMedium
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.isEnabled
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
