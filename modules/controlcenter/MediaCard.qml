import QtQuick
import QtQuick.Layouts
import "../../themes"
import "../../services" as Services

Rectangle {
    id: root

    width: parent ? parent.width : 400
    height: 104
    radius: Theme.radiusSmall
    color: Theme.panelSurface
    border.width: Theme.borderWidth
    border.color: Theme.subtleBorder
    clip: true

    function formatTime(seconds) {
        if (!seconds || seconds <= 0 || !isFinite(seconds))
            return "0:00";
        const total = Math.floor(seconds);
        const minutes = Math.floor(total / 60);
        const rest = total % 60;
        return minutes + ":" + (rest < 10 ? "0" : "") + rest;
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.lg
        spacing: Theme.spacing.md

        Rectangle {
            Layout.preferredWidth: 64
            Layout.preferredHeight: 64
            Layout.alignment: Qt.AlignVCenter
            radius: Theme.radiusSmall
            color: Theme.surfaceElevated
            clip: true

            Image {
                anchors.fill: parent
                source: Services.Media.artUrl
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: false
                visible: Services.Media.artUrl.length > 0
            }

            Text {
                anchors.centerIn: parent
                visible: Services.Media.artUrl.length === 0
                text: "\uf001"
                color: Theme.mutedForeground
                font.family: Theme.iconFontFamily
                font.pixelSize: Theme.fontSizeXLarge
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: Services.Media.available
            Layout.alignment: Services.Media.available ? Qt.AlignTop : Qt.AlignVCenter
            spacing: Theme.spacing.xs

            Text {
                Layout.fillWidth: true
                text: Services.Media.available ? Services.Media.title : "Nothing playing"
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                font.weight: Theme.fontWeightBold
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: Services.Media.available
                    ? (Services.Media.artist || Services.Media.album || "Unknown artist")
                    : "Start a media player to see playback here"
                color: Theme.mutedForeground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                elide: Text.ElideRight
            }

            Item {
                Layout.fillHeight: true
                visible: Services.Media.available
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.sm
                visible: Services.Media.available

                Text {
                    text: root.formatTime(Services.Media.position)
                    color: Theme.mutedForeground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }

                Item {
                    Layout.fillWidth: true
                    height: 8

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        height: 3
                        radius: 1.5
                        color: Theme.surfaceElevated
                    }

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width * Services.Media.progress
                        height: 3
                        radius: 1.5
                        color: Theme.primary
                    }
                }

                Text {
                    text: root.formatTime(Services.Media.length)
                    color: Theme.mutedForeground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.xl
                visible: Services.Media.available

                Item { Layout.fillWidth: true }

                Text {
                    text: "\uf048"
                    color: Services.Media.player && Services.Media.player.canGoPrevious
                        ? Theme.foreground : Theme.disabled
                    font.family: Theme.iconFontFamily
                    font.pixelSize: Theme.fontSizeMedium
                    MouseArea {
                        anchors.fill: parent
                        enabled: Services.Media.player && Services.Media.player.canGoPrevious
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Services.Media.previous()
                    }
                }

                Text {
                    text: Services.Media.playing ? "\uf04c" : "\uf04b"
                    color: Theme.foreground
                    font.family: Theme.iconFontFamily
                    font.pixelSize: Theme.fontSizeLarge
                    MouseArea {
                        anchors.fill: parent
                        enabled: Services.Media.available
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Services.Media.togglePlaying()
                    }
                }

                Text {
                    text: "\uf051"
                    color: Services.Media.player && Services.Media.player.canGoNext
                        ? Theme.foreground : Theme.disabled
                    font.family: Theme.iconFontFamily
                    font.pixelSize: Theme.fontSizeMedium
                    MouseArea {
                        anchors.fill: parent
                        enabled: Services.Media.player && Services.Media.player.canGoNext
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Services.Media.next()
                    }
                }

                Item { Layout.fillWidth: true }
            }
        }
    }
}
