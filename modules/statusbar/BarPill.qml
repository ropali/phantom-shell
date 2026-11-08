import QtQuick
import "../../config" as Config
import "../../themes"

Rectangle {
    id: root

    property int horizontalPadding: Theme.spacing.md + Theme.spacing.xs
    property int contentSpacing: Theme.spacing.sm
    property bool interactive: false

    signal clicked()

    implicitHeight: Math.max(Theme.buttonSize + Theme.spacing.sm,
        Config.Settings.barHeight - Theme.spacing.sm)
    implicitWidth: inner.implicitWidth + horizontalPadding * 2
    radius: height / 2
    color: root.interactive && pillMouse.containsMouse
        ? Theme.panelSurfaceHover : Theme.panelSurface
    border.width: Theme.borderWidth
    border.color: Theme.subtleBorder

    default property alias contentData: inner.data

    Behavior on color {
        ColorAnimation { duration: Theme.animationFast; easing.type: Theme.easingType }
    }

    MouseArea {
        id: pillMouse
        anchors.fill: parent
        enabled: root.interactive
        hoverEnabled: root.interactive
        cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }

    Row {
        id: inner
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: root.horizontalPadding
        spacing: root.contentSpacing
    }
}
