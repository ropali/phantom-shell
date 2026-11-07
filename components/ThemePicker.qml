import QtQuick
import "../themes"

Column {
    id: root

    width: parent ? parent.width : 300
    spacing: 2

    Repeater {
        model: ThemeManager.availableThemes

        delegate: Rectangle {
            id: themeRow
            required property var modelData

            readonly property bool active: ThemeManager.activeThemeId === modelData.id

            width: root.width
            height: Theme.controlHeight
            radius: Theme.radiusSmall
            color: active ? Theme.surfaceElevated
                : themeMouse.containsMouse ? Theme.surface
                : "transparent"
            border.width: active ? Theme.borderWidth : 0
            border.color: Theme.primary

            Row {
                anchors.left: parent.left
                anchors.leftMargin: Theme.spacing.sm
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.spacing.sm

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Repeater {
                        model: [
                            themeRow.modelData.colors.background,
                            themeRow.modelData.colors.surface,
                            themeRow.modelData.colors.primary,
                            themeRow.modelData.colors.secondary,
                            themeRow.modelData.colors.foreground
                        ]

                        delegate: Rectangle {
                            required property var modelData
                            width: Theme.spacing.md
                            height: Theme.spacing.md
                            radius: 2
                            color: modelData
                            border.width: Theme.borderWidth
                            border.color: Theme.border
                        }
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: themeRow.modelData.name
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeBase
                    font.weight: themeRow.active ? Theme.fontWeightBold : Theme.fontWeightNormal
                }
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: Theme.spacing.sm
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
