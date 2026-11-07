import QtQuick
import "../themes"

Item {
    id: root

    property string icon: ""
    property string tooltip: ""
    property bool active: false
    property color iconColor: Theme.foreground
    property int buttonSize: Theme.buttonSize
    property int iconSize: Theme.iconSize
    signal clicked(var mouse)

    implicitWidth: buttonSize
    implicitHeight: buttonSize

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.active ? Theme.surfaceElevated
            : mouseArea.containsMouse ? Theme.surface : "transparent"

        Behavior on color {
            ColorAnimation { duration: Theme.animationFast; easing.type: Theme.easingType }
        }
    }

    Text {
        anchors.centerIn: parent
        text: root.icon
        color: root.active ? Theme.primary : root.iconColor
        font.family: Theme.iconFontFamily
        font.pixelSize: root.iconSize
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: (mouse) => root.clicked(mouse)
    }

    Timer {
        id: tooltipTimer
        interval: 600
        running: mouseArea.containsMouse && root.tooltip.length > 0
        property bool ready: false
        onRunningChanged: if (!running) ready = false
        onTriggered: ready = true
    }

    Tooltip {
        anchorItem: root
        text: root.tooltip
        shown: tooltipTimer.ready
    }
}
