import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import "../../themes"
import "../../services" as Services

Rectangle {
    id: root

    width: parent ? parent.width : 400
    height: 80
    radius: Theme.radius
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

    // Map player identity/desktopEntry to icon + color
    readonly property string _id: (Services.Media.identity + " " + Services.Media.desktopEntry).toLowerCase()

    readonly property string playerIcon: {
        if (_id.includes("spotify"))   return "\uf1bc";  // fa-spotify
        if (_id.includes("firefox"))   return "\uf269";  // fa-firefox
        if (_id.includes("chrom"))     return "\uf268";  // fa-chrome (chrome/chromium)
        if (_id.includes("brave"))     return "\uf268";  // fa-chrome (brave is chromium-based)
        if (_id.includes("vlc"))       return "\uf144";  // fa-circle-play
        if (_id.includes("mpv"))       return "\uf144";  // fa-circle-play
        if (_id.includes("celluloid")) return "\uf144";  // fa-circle-play
        if (_id.includes("rhythmbox")) return "\uf001";  // fa-music
        if (_id.includes("amberol"))   return "\uf001";  // fa-music
        if (_id.includes("elisa"))     return "\uf001";  // fa-music
        return "\uf001";                                  // fa-music (generic fallback)
    }

    readonly property color playerColor: {
        if (_id.includes("spotify"))   return "#1DB954";
        if (_id.includes("firefox"))   return "#FF7139";
        if (_id.includes("chrom"))     return "#4285F4";
        if (_id.includes("brave"))     return "#FB542B";
        if (_id.includes("vlc"))       return "#FF8800";
        return Theme.mutedForeground;
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.md
        spacing: Theme.spacing.md

        // Album art — compact square
        Rectangle {
            Layout.preferredWidth: 56
            Layout.preferredHeight: 56
            Layout.alignment: Qt.AlignVCenter
            radius: Theme.radiusSmall
            color: Theme.surfaceElevated
            border.width: Theme.borderWidth
            border.color: Qt.rgba(255, 255, 255, 0.1)
            clip: true

            Image {
                anchors.fill: parent
                source: Services.Media.artUrl
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: false
                visible: Services.Media.artUrl.length > 0
            }

            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                visible: Services.Media.artUrl.length === 0
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.2) }
                    GradientStop { position: 1.0; color: Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.2) }
                }

                Text {
                    anchors.centerIn: parent
                    text: "\uf001"
                    color: Theme.mutedForeground
                    font.family: Theme.iconFontFamily
                    font.pixelSize: 22
                }
            }
        }

        // Right side — constrained to album art height
        Column {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            Layout.alignment: Qt.AlignVCenter
            spacing: 0

            // Row 1: Title + app icon
            RowLayout {
                width: parent.width
                height: 16
                spacing: Theme.spacing.sm

                Text {
                    Layout.fillWidth: true
                    text: Services.Media.available ? Services.Media.title : "Nothing playing"
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeBase
                    font.weight: Theme.fontWeightBold
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    verticalAlignment: Text.AlignVCenter
                }

                // App icon — detected from player identity
                Text {
                    visible: Services.Media.available
                    text: root.playerIcon
                    color: root.playerColor
                    font.family: Theme.iconFontFamily
                    font.pixelSize: Theme.fontSizeMedium
                }
            }

            // Row 2: Artist
            Text {
                width: parent.width
                height: 14
                text: Services.Media.available
                    ? (Services.Media.artist || Services.Media.album || "Unknown artist")
                    : "Start a media player to see playback here"
                color: Theme.mutedForeground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                elide: Text.ElideRight
                maximumLineCount: 1
                verticalAlignment: Text.AlignVCenter
            }

            // Spacer
            Item {
                width: 1
                height: 6
            }

            // Row 3: Progress bar
            Item {
                width: parent.width
                height: 4
                visible: Services.Media.available

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: 3
                    radius: 1.5
                    color: Qt.rgba(255, 255, 255, 0.15)
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width * Services.Media.progress
                    height: 3
                    radius: 1.5
                    color: Theme.foreground

                    Behavior on width {
                        NumberAnimation { duration: 1000; easing.type: Easing.Linear }
                    }
                }
            }

            // Spacer
            Item {
                width: 1
                height: Services.Media.available ? 4 : 0
            }

            // Row 4: Time + controls + time (all inline)
            RowLayout {
                width: parent.width
                height: 16
                spacing: 0
                visible: Services.Media.available

                // Elapsed time
                Text {
                    text: root.formatTime(Services.Media.position)
                    color: Theme.mutedForeground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeTiny
                    verticalAlignment: Text.AlignVCenter
                }

                Item { Layout.fillWidth: true }

                // Controls: prev | play/pause | next
                Row {
                    spacing: Theme.spacing.md
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        text: "\uf048"
                        color: Services.Media.player && Services.Media.player.canGoPrevious
                            ? Theme.foreground : Theme.disabled
                        font.family: Theme.iconFontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        verticalAlignment: Text.AlignVCenter

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -4
                            enabled: Services.Media.player && Services.Media.player.canGoPrevious
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Services.Media.previous()
                        }
                    }

                    Text {
                        text: Services.Media.playing ? "\uf04c" : "\uf04b"
                        color: Theme.foreground
                        font.family: Theme.iconFontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        verticalAlignment: Text.AlignVCenter

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -4
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
                        font.pixelSize: Theme.fontSizeSmall
                        verticalAlignment: Text.AlignVCenter

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -4
                            enabled: Services.Media.player && Services.Media.player.canGoNext
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Services.Media.next()
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // Total time
                Text {
                    text: root.formatTime(Services.Media.length)
                    color: Theme.mutedForeground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeTiny
                    verticalAlignment: Text.AlignVCenter
                }
            }

            // Nothing-playing bottom spacer for centering
            Item {
                width: 1
                Layout.fillHeight: true
                visible: !Services.Media.available
            }
        }
    }
}
