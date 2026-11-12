import QtQuick
import "../themes"

Item {
    id: root

    property string title: ""
    property string description: ""
    default property alias content: body.data

    width: parent ? parent.width : 400
    height: contentColumn.implicitHeight + Theme.spacing.lg * 2

    HoverHandler {
        id: cardHover
    }

    Rectangle {
        id: card
        anchors.fill: parent
        radius: Theme.radius
        color: Theme.panelSurface
        border.width: Theme.borderWidth
        border.color: cardHover.hovered ? Theme.accentBorder : Theme.subtleBorder

        Behavior on border.color {
            ColorAnimation { duration: Theme.animationFast; easing.type: Theme.easingType }
        }

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            opacity: cardHover.hovered ? 1.0 : 0.45
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop {
                    position: 0.0
                    color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.07)
                }
                GradientStop { position: 0.42; color: "transparent" }
            }

            Behavior on opacity {
                NumberAnimation { duration: Theme.animationFast }
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: 1
            anchors.verticalCenter: parent.verticalCenter
            width: 2
            height: parent.height - Theme.spacing.lg
            radius: 1
            color: cardHover.hovered
                ? Theme.primary
                : Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.28)

            Behavior on color {
                ColorAnimation { duration: Theme.animationFast }
            }
        }
    }

    Rectangle {
        anchors.fill: card
        anchors.margins: -2
        y: 4
        z: -1
        radius: card.radius + 2
        color: Qt.rgba(0, 0, 0, 0.16)
    }

    Column {
        id: contentColumn
        x: Theme.spacing.lg
        y: Theme.spacing.lg
        width: parent.width - Theme.spacing.lg * 2
        spacing: Theme.spacing.md

        Column {
            width: parent.width
            spacing: 2
            visible: root.title.length > 0 || root.description.length > 0

            Text {
                width: parent.width
                visible: root.title.length > 0
                text: root.title
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMedium
                font.weight: Theme.fontWeightBold
                font.letterSpacing: 0.2
            }

            Text {
                width: parent.width
                visible: root.description.length > 0
                text: root.description
                color: Theme.mutedForeground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                lineHeight: Theme.lineHeight
            }
        }

        Column {
            id: body
            width: parent.width
            spacing: Theme.spacing.md
        }
    }
}
