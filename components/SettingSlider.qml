import QtQuick
import QtQuick.Layouts
import "../themes"

Column {
    id: root

    property string label: ""
    property string valueText: ""
    property real value: 0
    property real from: 0
    property real to: 1
    property bool isEnabled: true
    signal moved(real value)

    width: parent ? parent.width : 300
    spacing: Theme.spacing.xs
    opacity: enabled ? 1 : 0.45

    RowLayout {
        width: parent.width

        Text {
            Layout.fillWidth: true
            text: root.label
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeBase
        }

        Text {
            text: root.valueText
            color: Theme.mutedForeground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
        }
    }

    Item {
        id: slider
        width: parent.width
        height: Theme.spacing.lg

        readonly property real ratio: root.to === root.from
            ? 0 : Math.max(0, Math.min(1, (root.value - root.from) / (root.to - root.from)))

        Rectangle {
            id: track
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: Theme.spacing.sm
            radius: Theme.spacing.xs
            color: Theme.surfaceElevated
        }

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: track.width * slider.ratio
            height: track.height
            radius: track.radius
            color: Theme.primary
        }

        Rectangle {
            width: Theme.spacing.md
            height: Theme.spacing.md
            radius: width / 2
            anchors.verticalCenter: parent.verticalCenter
            x: Math.max(0, Math.min(slider.width - width, slider.width * slider.ratio - width / 2))
            color: Theme.foreground
        }

        MouseArea {
            anchors.fill: parent
            enabled: root.isEnabled
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: (mouse) => root.moved(root.from + (root.to - root.from) * Math.max(0, Math.min(1, mouse.x / slider.width)))
            onPositionChanged: (mouse) => {
                if (pressed)
                    root.moved(root.from + (root.to - root.from) * Math.max(0, Math.min(1, mouse.x / slider.width)));
            }
        }
    }
}
