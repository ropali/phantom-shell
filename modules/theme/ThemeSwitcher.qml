import QtQuick
import "../../themes"
import "../../components" as Components

Components.Popup {
    id: root

    popupWidth: 300
    padding: Theme.padding
    spacing: Theme.spacing.md

    Text {
        width: parent.width
        text: "Theme"
        color: Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.weight: Theme.fontWeightBold
    }

    Repeater {
        model: ThemeManager.availableThemes

        delegate: Rectangle {
            id: themeRow
            required property var modelData

            readonly property bool active: ThemeManager.activeThemeId === modelData.id

            width: root.popupWidth - root.padding * 2
            height: Theme.controlHeight + Theme.spacing.sm
            radius: Theme.radiusSmall
            color: active ? Theme.surfaceElevated
                : themeMouse.containsMouse ? Theme.surface
                : "transparent"
            border.width: active ? Theme.borderWidth : 0
            border.color: Theme.primary

            Row {
                anchors.left: parent.left
                anchors.leftMargin: Theme.spacing.md
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.spacing.sm

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.spacing.xs

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
                            width: Theme.spacing.lg
                            height: Theme.spacing.lg
                            radius: Theme.spacing.xs
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

    Text {
        width: parent.width
        visible: ThemeManager.availableThemes.length === 0
        text: "No themes found"
        color: Theme.mutedForeground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
    }

    Text {
        width: parent.width
        text: "Add custom themes to themes/custom/*.json"
        color: Theme.mutedForeground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeTiny
        wrapMode: Text.WordWrap
    }
}
