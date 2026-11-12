import QtQuick
import "../themes"

Column {
    id: root

    width: parent ? parent.width : 300
    spacing: 4

    Repeater {
        model: ThemeManager.availableThemes

        delegate: Rectangle {
            id: themeRow

            required property var modelData

            readonly property bool active: ThemeManager.activeThemeId === modelData.id

            width: root.width
            height: 42
            radius: Theme.radiusSmall
            color: active ? Theme.accentSurface
                : themeMouse.containsMouse ? Theme.surface
                : Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.35)
            border.width: active ? Theme.borderWidth : 0
            border.color: Theme.accentBorder

            Behavior on color {
                ColorAnimation { duration: Theme.animationFast; easing.type: Theme.easingType }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.leftMargin: Theme.spacing.sm
                anchors.verticalCenter: parent.verticalCenter
                width: 48
                height: 26
                radius: 7
                color: themeRow.modelData.colors.background
                border.width: Theme.borderWidth
                border.color: themeRow.active ? Theme.primary : Theme.subtleBorder
                clip: true

                Row {
                    anchors.fill: parent
                    anchors.margins: 2
                    spacing: 0

                    Repeater {
                        model: [
                            themeRow.modelData.colors.primary,
                            themeRow.modelData.colors.secondary,
                            themeRow.modelData.colors.tertiary,
                            themeRow.modelData.colors.foreground
                        ]

                        delegate: Rectangle {
                            required property var modelData
                            width: 11
                            height: parent.height
                            color: modelData
                        }
                    }
                }
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 48 + Theme.spacing.sm * 2
                anchors.right: parent.right
                anchors.rightMargin: themeRow.active ? 30 : Theme.spacing.md
                anchors.verticalCenter: parent.verticalCenter
                text: themeRow.modelData.name
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeBase
                font.weight: themeRow.active ? Theme.fontWeightBold : Theme.fontWeightNormal
                elide: Text.ElideRight
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: Theme.spacing.md
                anchors.verticalCenter: parent.verticalCenter
                visible: themeRow.active
                text: "\uf00c"
                color: Theme.primary
                font.family: Theme.iconFontFamily
                font.pixelSize: Theme.fontSizeSmall
            }

            MouseArea {
                id: themeMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: ThemeManager.applyTheme(themeRow.modelData.id)
            }
        }
    }
}
