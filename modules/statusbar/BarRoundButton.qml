import QtQuick
import "../../config" as Config
import "../../themes"
import "../../components" as Components

Item {
    id: root

    property string icon: ""
    property string tooltip: ""
    property color iconColor: Theme.foreground
    property bool active: false

    signal clicked()

    implicitWidth: Math.max(Theme.buttonSize + Theme.spacing.sm,
        Config.Settings.barHeight - Theme.spacing.sm)
    implicitHeight: implicitWidth

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.active ? Theme.primary
            : mouseArea.containsMouse ? Theme.panelSurfaceHover
            : Theme.panelSurface
        border.width: Theme.borderWidth
        border.color: root.active ? Theme.primary : Theme.subtleBorder

        Behavior on color {
            ColorAnimation { duration: Theme.animationFast; easing.type: Theme.easingType }
        }
    }

    Text {
        anchors.centerIn: parent
        text: root.icon
        color: root.active ? Theme.onPrimary : root.iconColor
        font.family: Theme.iconFontFamily
        font.pixelSize: Theme.fontSize
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    Timer {
        id: tooltipTimer
        interval: 600
        running: mouseArea.containsMouse && root.tooltip.length > 0
        property bool ready: false
        onRunningChanged: if (!running) ready = false
        onTriggered: ready = true
    }

    Components.Tooltip {
        anchorItem: root
        text: root.tooltip
        shown: tooltipTimer.ready
    }
}
