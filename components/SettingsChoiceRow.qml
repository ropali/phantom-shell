import QtQuick
import QtQuick.Layouts
import "../themes"

Item {
    id: root

    property string title: ""
    property string description: ""
    property var options: []
    property string current: ""
    signal selected(string id)

    width: parent ? parent.width : 300
    height: Math.max(Theme.rowHeight, textColumn.implicitHeight + Theme.spacing.md)

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.spacing.sm
        anchors.rightMargin: Theme.spacing.sm
        spacing: Theme.spacing.md

        Column {
            id: textColumn
            Layout.fillWidth: true
            spacing: 2

            Text {
                width: parent.width
                text: root.title
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeBase
                font.weight: Theme.fontWeightMedium
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
            Layout.preferredWidth: optionRow.implicitWidth + 6
            Layout.preferredHeight: 30
            radius: Theme.radiusSmall
            color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.7)
            border.width: Theme.borderWidth
            border.color: Theme.subtleBorder

            Row {
                id: optionRow
                anchors.centerIn: parent
                spacing: 2

                Repeater {
                    model: root.options

                    delegate: Rectangle {
                        id: option

                        required property var modelData

                        readonly property bool active: root.current === modelData.id

                        width: optionLabel.implicitWidth + Theme.spacing.md * 2
                        height: 24
                        radius: Theme.radiusSmall
                        color: optionMouse.containsMouse && !active
                            ? Theme.surfaceElevated : "transparent"

                        Behavior on color {
                            ColorAnimation { duration: Theme.animationFast }
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: parent.radius
                            opacity: option.active ? 1.0 : 0.0
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: Theme.primary }
                                GradientStop { position: 1.0; color: Theme.secondary }
                            }

                            Behavior on opacity {
                                NumberAnimation { duration: Theme.animationFast }
                            }
                        }

                        Text {
                            id: optionLabel
                            anchors.centerIn: parent
                            text: modelData.label
                            color: option.active ? Theme.onPrimary : Theme.mutedForeground
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: option.active ? Theme.fontWeightBold : Theme.fontWeightNormal
                        }

                        MouseArea {
                            id: optionMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.selected(modelData.id)
                        }
                    }
                }
            }
        }
    }
}
