import QtQuick
import "../themes"

Item {
    id: root

    property real value: 0
    property real from: 0
    property real to: 1
    property bool isEnabled: true
    signal moved(real value)

    width: parent ? parent.width : 100
    height: Theme.spacing.xl + Theme.spacing.sm
    opacity: isEnabled ? 1 : 0.45

    readonly property real ratio: to === from
        ? 0 : Math.max(0, Math.min(1, (value - from) / (to - from)))

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 6
        radius: height / 2
        color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.08)
        border.width: Theme.borderWidth
        border.color: Theme.subtleBorder
    }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: Math.max(0, track.width * root.ratio)
        height: track.height
        radius: track.radius
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Theme.primary }
            GradientStop { position: 1.0; color: Theme.secondary }
        }
    }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 24
        height: 24
        radius: 12
        x: Math.max(-12, Math.min(root.width - 12, root.width * root.ratio - 12))
        color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.20)
        opacity: mouseArea.containsMouse || mouseArea.pressed ? 1.0 : 0.0
        scale: mouseArea.containsMouse || mouseArea.pressed ? 1.0 : 0.7

        Behavior on opacity {
            NumberAnimation { duration: Theme.animationFast }
        }

        Behavior on scale {
            NumberAnimation { duration: Theme.animationFast; easing.type: Easing.OutCubic }
        }
    }

    Rectangle {
        id: thumb
        width: Theme.spacing.lg + Theme.spacing.xs
        height: width
        radius: width / 2
        anchors.verticalCenter: parent.verticalCenter
        x: Math.max(0, Math.min(root.width - width, root.width * root.ratio - width / 2))
        color: Theme.foreground
        border.width: Theme.borderWidth
        border.color: Theme.primary
        scale: mouseArea.pressed ? 1.12 : 1.0

        Behavior on scale {
            NumberAnimation { duration: Theme.animationFast; easing.type: Easing.OutBack }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        anchors.topMargin: -Theme.spacing.xs
        anchors.bottomMargin: -Theme.spacing.xs
        enabled: root.isEnabled
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: (mouse) => root.moved(root.from + (root.to - root.from)
            * Math.max(0, Math.min(1, mouse.x / root.width)))
        onPositionChanged: (mouse) => {
            if (pressed)
                root.moved(root.from + (root.to - root.from)
                    * Math.max(0, Math.min(1, mouse.x / root.width)));
        }
    }
}
