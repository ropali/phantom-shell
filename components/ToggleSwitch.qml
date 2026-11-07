import QtQuick
import "../themes"

Rectangle {
    id: root

    property bool checked: false
    signal toggled

    width: Theme.spacing.xl * 2 + Theme.spacing.xs
    height: Theme.spacing.xl + Theme.spacing.sm
    radius: height / 2
    color: checked ? Theme.primary : Theme.surfaceElevated

    Behavior on color {
        ColorAnimation { duration: Theme.animationFast; easing.type: Theme.easingType }
    }

    Rectangle {
        width: Theme.spacing.xl
        height: Theme.spacing.xl
        radius: width / 2
        y: Theme.spacing.xs
        x: root.checked ? root.width - width - Theme.spacing.xs : Theme.spacing.xs
        color: root.checked ? Theme.onPrimary : Theme.foreground

        Behavior on x {
            NumberAnimation { duration: Theme.animationFast; easing.type: Theme.easingType }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
}
