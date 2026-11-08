import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import "../../themes"
import "../../services" as Services

Rectangle {
    id: root

    width: parent ? parent.width : 400
    height: 124
    radius: Theme.radius
    color: Theme.panelSurface
    border.width: Theme.borderWidth
    border.color: Services.Media.available 
        ? Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.3)
        : Theme.subtleBorder
    clip: true
    
    Behavior on border.color {
        ColorAnimation { duration: Theme.animationNormal }
    }
    
    // Animated gradient background when playing
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        opacity: Services.Media.playing ? 0.06 : 0
        visible: Services.Media.available
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Theme.secondary }
            GradientStop { position: 0.5; color: Theme.primary }
            GradientStop { position: 1.0; color: Theme.tertiary }
        }
        
        Behavior on opacity {
            NumberAnimation { duration: Theme.animationSlow }
        }
    }

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
        anchors.margins: Theme.spacing.md
        spacing: Theme.spacing.md

        Rectangle {
            Layout.preferredWidth: 76
            Layout.preferredHeight: 76
            Layout.alignment: Qt.AlignVCenter
            radius: Theme.radius
            color: Theme.surfaceElevated
            border.width: Theme.borderWidth
            border.color: Services.Media.available 
                ? Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.4)
                : Theme.subtleBorder
            clip: true
            
            layer.enabled: Services.Media.artUrl.length > 0
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Qt.rgba(0, 0, 0, 0.4)
                shadowBlur: 0.8
                shadowVerticalOffset: 3
            }

            Image {
                anchors.fill: parent
                source: Services.Media.artUrl
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: false
                visible: Services.Media.artUrl.length > 0
                
                scale: Services.Media.playing ? 1.0 : 0.95
                Behavior on scale {
                    NumberAnimation { duration: Theme.animationNormal; easing.type: Easing.OutQuad }
                }
            }

            Rectangle {
                anchors.fill: parent
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
                    font.pixelSize: 32
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // Title and artist section
            Column {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    width: parent.width
                    text: Services.Media.available ? Services.Media.title : "Nothing playing"
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeBase
                    font.weight: Theme.fontWeightBold
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                Text {
                    width: parent.width
                    text: Services.Media.available
                        ? (Services.Media.artist || Services.Media.album || "Unknown artist")
                        : "Start a media player to see playback here"
                    color: Theme.mutedForeground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }
            }

            // Flexible spacer
            Item {
                Layout.fillHeight: true
                Layout.minimumHeight: Services.Media.available ? 6 : 0
            }

            // Progress bar section
            Column {
                Layout.fillWidth: true
                spacing: 4
                visible: Services.Media.available

                Item {
                    width: parent.width
                    height: 10

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        height: 4
                        radius: 2
                        color: Qt.rgba(Theme.surfaceElevated.r, Theme.surfaceElevated.g, Theme.surfaceElevated.b, 0.8)
                    }

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width * Services.Media.progress
                        height: 4
                        radius: 2
                        
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: Theme.primary }
                            GradientStop { position: 1.0; color: Theme.secondary }
                        }
                        
                        Behavior on width {
                            NumberAnimation { duration: 1000; easing.type: Easing.Linear }
                        }
                    }
                    
                    // Progress indicator dot
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        x: parent.width * Services.Media.progress - width / 2
                        width: 8
                        height: 8
                        radius: 4
                        color: Theme.primary
                        visible: Services.Media.playing
                        
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            shadowEnabled: true
                            shadowColor: Theme.primary
                            shadowBlur: 0.8
                        }
                        
                        Behavior on x {
                            NumberAnimation { duration: 1000; easing.type: Easing.Linear }
                        }
                    }
                }

                RowLayout {
                    width: parent.width
                    spacing: 0

                    Text {
                        text: root.formatTime(Services.Media.position)
                        color: Theme.mutedForeground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeTiny
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: root.formatTime(Services.Media.length)
                        color: Theme.mutedForeground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeTiny
                    }
                }
            }

            // Spacer before controls
            Item {
                Layout.fillHeight: true
                Layout.minimumHeight: Services.Media.available ? 6 : 0
            }

            // Controls section
            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: Theme.spacing.lg
                visible: Services.Media.available

                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: prevMouse.containsMouse && Services.Media.player && Services.Media.player.canGoPrevious
                        ? Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.1)
                        : "transparent"
                    
                    Behavior on color {
                        ColorAnimation { duration: Theme.animationFast }
                    }
                    
                    scale: prevMouse.pressed ? 0.9 : 1.0
                    Behavior on scale {
                        NumberAnimation { duration: 100 }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "\uf048"
                        color: Services.Media.player && Services.Media.player.canGoPrevious
                            ? Theme.foreground : Theme.disabled
                        font.family: Theme.iconFontFamily
                        font.pixelSize: Theme.fontSizeMedium
                    }
                    
                    MouseArea {
                        id: prevMouse
                        anchors.fill: parent
                        enabled: Services.Media.player && Services.Media.player.canGoPrevious
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Services.Media.previous()
                    }
                }

                Rectangle {
                    width: 40
                    height: 40
                    radius: 20
                    color: playMouse.containsMouse 
                        ? Theme.primary
                        : Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.9)
                    
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowColor: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.5)
                        shadowBlur: 0.8
                        shadowVerticalOffset: 2
                    }
                    
                    Behavior on color {
                        ColorAnimation { duration: Theme.animationFast }
                    }
                    
                    scale: playMouse.pressed ? 0.9 : 1.0
                    Behavior on scale {
                        NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: Services.Media.playing ? "\uf04c" : "\uf04b"
                        color: Theme.onPrimary
                        font.family: Theme.iconFontFamily
                        font.pixelSize: Theme.fontSizeMedium
                    }
                    
                    MouseArea {
                        id: playMouse
                        anchors.fill: parent
                        enabled: Services.Media.available
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Services.Media.togglePlaying()
                    }
                }

                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: nextMouse.containsMouse && Services.Media.player && Services.Media.player.canGoNext
                        ? Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.1)
                        : "transparent"
                    
                    Behavior on color {
                        ColorAnimation { duration: Theme.animationFast }
                    }
                    
                    scale: nextMouse.pressed ? 0.9 : 1.0
                    Behavior on scale {
                        NumberAnimation { duration: 100 }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "\uf051"
                        color: Services.Media.player && Services.Media.player.canGoNext
                            ? Theme.foreground : Theme.disabled
                        font.family: Theme.iconFontFamily
                        font.pixelSize: Theme.fontSizeMedium
                    }
                    
                    MouseArea {
                        id: nextMouse
                        anchors.fill: parent
                        enabled: Services.Media.player && Services.Media.player.canGoNext
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Services.Media.next()
                    }
                }
            }
        }
    }
}
