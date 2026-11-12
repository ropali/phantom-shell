import QtQuick
import QtQuick.Layouts
import "../themes"

Flickable {
    id: root

    property string title: ""
    property string description: ""
    property string icon: "\uf013"
    property string eyebrow: ""
    default property alias content: body.data

    readonly property string eyebrowText: eyebrow.length > 0
        ? eyebrow : "PHANTOM / " + title.toUpperCase()

    contentWidth: width
    contentHeight: contentColumn.implicitHeight + Theme.spacing.lg
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    interactive: contentHeight > height

    Column {
        id: contentColumn
        width: root.width
        spacing: Theme.spacing.lg

        Rectangle {
            width: parent.width
            height: Math.max(112, heroRow.implicitHeight + Theme.spacing.lg * 2)
            radius: Theme.radiusLarge
            color: Theme.panelSurface
            border.width: Theme.borderWidth
            border.color: Theme.subtleBorder
            clip: true

            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop {
                        position: 0.0
                        color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.14)
                    }
                    GradientStop { position: 0.55; color: "transparent" }
                    GradientStop {
                        position: 1.0
                        color: Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.08)
                    }
                }
            }

            Rectangle {
                width: 220
                height: 220
                radius: width / 2
                x: parent.width - 150
                y: -120
                color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.08)
            }

            RowLayout {
                id: heroRow
                anchors.fill: parent
                anchors.margins: Theme.spacing.lg
                spacing: Theme.spacing.lg

                Item {
                    Layout.preferredWidth: 56
                    Layout.preferredHeight: 56
                    Layout.alignment: Qt.AlignVCenter

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -4
                        radius: height / 2
                        color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.14)
                        scale: 1.08
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.radius
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: Theme.primary }
                            GradientStop { position: 1.0; color: Theme.secondary }
                        }
                        border.width: Theme.borderWidth
                        border.color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.20)
                    }

                    Text {
                        anchors.centerIn: parent
                        text: root.icon
                        color: Theme.onPrimary
                        font.family: Theme.iconFontFamily
                        font.pixelSize: Theme.fontSizeXLarge
                    }
                }

                Column {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 3

                    Text {
                        width: parent.width
                        text: root.eyebrowText
                        color: Theme.primary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeTiny
                        font.weight: Theme.fontWeightBold
                        font.letterSpacing: 1.3
                    }

                    Text {
                        width: parent.width
                        text: root.title
                        color: Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeXLarge + 4
                        font.weight: Theme.fontWeightBold
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

                Rectangle {
                    Layout.alignment: Qt.AlignVCenter
                    visible: root.width > 560
                    width: liveRow.implicitWidth + Theme.spacing.lg
                    height: 26
                    radius: height / 2
                    color: Theme.accentSurface
                    border.width: Theme.borderWidth
                    border.color: Theme.accentBorder

                    Row {
                        id: liveRow
                        anchors.centerIn: parent
                        spacing: Theme.spacing.xs

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 6
                            height: 6
                            radius: 3
                            color: Theme.success
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "APPLIES LIVE"
                            color: Theme.primary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeTiny
                            font.weight: Theme.fontWeightBold
                            font.letterSpacing: 0.5
                        }
                    }
                }
            }
        }

        Column {
            id: body
            width: parent.width
            spacing: Theme.spacing.md
        }
    }
}
