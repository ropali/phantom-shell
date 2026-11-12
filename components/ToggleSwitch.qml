import QtQuick
import "../themes"

Rectangle {
    id: root

    property bool checked: false
    signal toggled()

    width: Theme.spacing.xl * 2 + Theme.spacing.md
    height: Theme.spacing.xl + Theme.spacing.sm
    radius: height / 2
    color: checked ? Theme.primary : Theme.surfaceElevated
    border.width: Theme.borderWidth
    border.color: checked ? Theme.accentBorder : Theme.subtleBorder
    scale: mouseArea.pressed ? 0.96 : mouseArea.containsMouse ? 1.03 : 1.0

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
        opacity: root.checked ? 1.0 : 0.0
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.0) }
            GradientStop { position: 1.0; color: Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.65) }
        }

        Behavior on opacity {
            NumberAnimation { duration: Theme.animationFast }
        }
    }

    Rectangle {
        width: Theme.spacing.xl + Theme.spacing.md
        height: width
        radius: width / 2
        anchors.verticalCenter: parent.verticalCenter
        x: thumb.x + (thumb.width - width) / 2
        color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.25)
        opacity: root.checked ? 1.0 : 0.0

        Behavior on x {
            NumberAnimation { duration: Theme.animationFast; easing.type: Theme.easingType }
        }

        Behavior on opacity {
            NumberAnimation { duration: Theme.animationFast }
        }
    }

    Rectangle {
        id: thumb
        width: Theme.spacing.xl
        height: width
        radius: width / 2
        anchors.verticalCenter: parent.verticalCenter
        x: root.checked ? parent.width - width - Theme.spacing.xs : Theme.spacing.xs
        color: root.checked ? Theme.onPrimary : Theme.foreground
        border.width: Theme.borderWidth
        border.color: root.checked
            ? Qt.rgba(Theme.onPrimary.r, Theme.onPrimary.g, Theme.onPrimary.b, 0.35)
            : Theme.border

        Behavior on x {
            NumberAnimation { duration: Theme.animationFast; easing.type: Theme.easingType }
        }

        Behavior on color {
            ColorAnimation { duration: Theme.animationFast }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
}
