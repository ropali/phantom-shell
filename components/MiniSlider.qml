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
    height: Theme.spacing.lg + Theme.spacing.xs
    opacity: isEnabled ? 1 : 0.45

    readonly property real ratio: to === from
        ? 0 : Math.max(0, Math.min(1, (value - from) / (to - from)))

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: Theme.spacing.sm
        radius: height / 2
        color: Theme.surfaceElevated
    }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: track.width * root.ratio
        height: track.height
        radius: track.radius
        color: Theme.primary
    }

    Rectangle {
        width: Theme.spacing.md + Theme.spacing.xs
        height: width
        radius: width / 2
        anchors.verticalCenter: parent.verticalCenter
        x: Math.max(0, Math.min(root.width - width, root.width * root.ratio - width / 2))
        color: Theme.foreground
        visible: root.isEnabled
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.isEnabled
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: (mouse) => root.moved(root.from + (root.to - root.from) * Math.max(0, Math.min(1, mouse.x / root.width)))
        onPositionChanged: (mouse) => {
            if (pressed)
                root.moved(root.from + (root.to - root.from) * Math.max(0, Math.min(1, mouse.x / root.width)));
        }
    }
}
