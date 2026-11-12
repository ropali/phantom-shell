import QtQuick
import QtQuick.Layouts
import "../../themes"
import "../../components" as Components
import "../../services" as Services

Item {
    id: root

    property var categories: []
    property string currentId: "panel"
    property string query: ""
    signal selected(string id)

    readonly property var filtered: {
        const text = query.trim().toLowerCase();
        if (text.length === 0)
            return categories;
        return categories.filter(category =>
            (category.title + " " + category.description).toLowerCase().indexOf(text) !== -1);
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.radius
        color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.28)
        border.width: Theme.borderWidth
        border.color: Theme.subtleBorder

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop {
                    position: 0.0
                    color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.05)
                }
                GradientStop { position: 0.7; color: "transparent" }
            }
        }
    }

    Item {
        anchors.fill: parent
        anchors.margins: Theme.spacing.md

        RowLayout {
            id: header
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 46
            spacing: Theme.spacing.md

            Item {
                Layout.preferredWidth: 42
                Layout.preferredHeight: 42
                Layout.alignment: Qt.AlignVCenter

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -3
                    radius: height / 2
                    color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.14)
                }

                Rectangle {
                    anchors.fill: parent
                    radius: Theme.radiusSmall
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Theme.primary }
                        GradientStop { position: 1.0; color: Theme.secondary }
                    }
                    border.width: Theme.borderWidth
                    border.color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.2)
                }

                Text {
                    anchors.centerIn: parent
                    text: "P"
                    color: Theme.onPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeXLarge
                    font.weight: Theme.fontWeightBold
                }
            }

            Column {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 0

                Text {
                    width: parent.width
                    text: "Phantom"
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeLarge
                    font.weight: Theme.fontWeightBold
                }

                Text {
                    width: parent.width
                    text: "Desktop shell"
                    color: Theme.mutedForeground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeTiny
                }
            }

            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                visible: root.width > 250
                width: devLabel.implicitWidth + Theme.spacing.md
                height: 20
                radius: height / 2
                color: Theme.accentSurface
                border.width: Theme.borderWidth
                border.color: Theme.accentBorder

                Text {
                    id: devLabel
                    anchors.centerIn: parent
                    text: "DEV"
                    color: Theme.primary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeTiny
                    font.weight: Theme.fontWeightBold
                    font.letterSpacing: 0.8
                }
            }
        }

        Components.SettingsTextField {
            id: search
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: header.bottom
            anchors.topMargin: Theme.spacing.md
            leadingIcon: "\uf002"
            value: root.query
            placeholder: "Search settings"
            onEdited: (text) => root.query = text

            Keys.onDownPressed: nav.forceActiveFocus()
            Keys.onEscapePressed: Services.UiState.closeSettings()
        }

        Text {
            id: navLabel
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: search.bottom
            anchors.topMargin: Theme.spacing.md
            text: "NAVIGATION"
            color: Theme.mutedForeground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeTiny
            font.weight: Theme.fontWeightBold
            font.letterSpacing: 1.3
        }

        ListView {
            id: nav
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: navLabel.bottom
            anchors.topMargin: Theme.spacing.sm
            anchors.bottom: footer.top
            anchors.bottomMargin: Theme.spacing.sm
            clip: true
            spacing: 3
            model: root.filtered
            activeFocusOnTab: true
            boundsBehavior: Flickable.StopAtBounds

            function step(delta) {
                if (root.filtered.length === 0)
                    return;
                let index = 0;
                for (let i = 0; i < root.filtered.length; i++) {
                    if (root.filtered[i].id === root.currentId) {
                        index = i;
                        break;
                    }
                }
                index = Math.max(0, Math.min(root.filtered.length - 1, index + delta));
                currentIndex = index;
                root.selected(root.filtered[index].id);
            }

            Keys.onUpPressed: step(-1)
            Keys.onDownPressed: step(1)

            delegate: Item {
                id: row

                required property var modelData
                required property int index

                readonly property bool active: root.currentId === modelData.id

                width: nav.width
                height: 44

                Rectangle {
                    anchors.fill: parent
                    radius: Theme.radiusSmall
                    color: row.active ? Theme.accentSurface
                        : rowMouse.containsMouse
                            ? Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.65)
                            : "transparent"
                    border.width: row.active ? Theme.borderWidth : 0
                    border.color: Theme.accentBorder

                    Behavior on color {
                        ColorAnimation { duration: Theme.animationFast; easing.type: Theme.easingType }
                    }
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.leftMargin: 1
                    anchors.verticalCenter: parent.verticalCenter
                    visible: row.active
                    width: 2
                    height: 20
                    radius: 1
                    color: Theme.primary
                }

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.spacing.sm
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.spacing.sm
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.spacing.md

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 8
                        color: row.active
                            ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.20)
                            : Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.55)
                        border.width: Theme.borderWidth
                        border.color: row.active ? Theme.accentBorder : Theme.subtleBorder

                        Behavior on color {
                            ColorAnimation { duration: Theme.animationFast }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: modelData.icon
                            color: row.active ? Theme.primary : Theme.mutedForeground
                            font.family: Theme.iconFontFamily
                            font.pixelSize: Theme.fontSizeMedium
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 28 - Theme.spacing.md
                        text: modelData.title
                        color: row.active ? Theme.foreground : Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeBase
                        font.weight: row.active ? Theme.fontWeightBold : Theme.fontWeightNormal
                        elide: Text.ElideRight
                    }
                }

                Rectangle {
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.spacing.sm
                    anchors.verticalCenter: parent.verticalCenter
                    visible: row.active
                    width: 5
                    height: 5
                    radius: 3
                    color: Theme.primary
                }

                MouseArea {
                    id: rowMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        nav.currentIndex = index;
                        nav.forceActiveFocus();
                        root.selected(modelData.id);
                    }
                }
            }
        }

        Rectangle {
            id: footer
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 36
            radius: Theme.radiusSmall
            color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.55)
            border.width: Theme.borderWidth
            border.color: Theme.subtleBorder

            Row {
                anchors.centerIn: parent
                spacing: Theme.spacing.sm

                Rectangle {
                    width: keyLabel.implicitWidth + Theme.spacing.sm * 2
                    height: 22
                    radius: 6
                    color: Theme.surfaceElevated
                    border.width: Theme.borderWidth
                    border.color: Theme.border

                    Text {
                        id: keyLabel
                        anchors.centerIn: parent
                        text: "SUPER + ,"
                        color: Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeTiny
                        font.weight: Theme.fontWeightBold
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "open anywhere"
                    color: Theme.mutedForeground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeTiny
                }
            }
        }
    }
}
