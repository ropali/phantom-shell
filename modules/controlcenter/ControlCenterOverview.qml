import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Services.UPower
import "../../themes"
import "../../services" as Services
import "../../components" as Components

Item {
    id: root

    signal openDetail(string id)
    signal powerRequested()
    signal closeRequested()

    readonly property color batteryColor: !Services.Battery.available ? Theme.mutedForeground
        : Services.Battery.percentage <= 15 ? Theme.error
        : Services.Battery.percentage <= 30 ? Theme.warning
        : Theme.success

    implicitHeight: content.implicitHeight + Theme.spacing.xl * 2

    // Background gradient overlay for depth
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.02) }
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0) }
        }
    }

    Column {
        id: content
        anchors.fill: parent
        anchors.margins: Theme.spacing.xl
        spacing: Theme.spacing.lg

        // Header with gradient accent
        Rectangle {
            width: parent.width
            height: 36
            radius: Theme.radiusSmall
            color: "transparent"
            
            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                opacity: 0.05
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: Theme.primary }
                    GradientStop { position: 1.0; color: Theme.secondary }
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.spacing.md
                anchors.rightMargin: Theme.spacing.md
                spacing: Theme.spacing.md

                Rectangle {
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    radius: Theme.radiusSmall
                    color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.15)
                    
                    Text {
                        anchors.centerIn: parent
                        text: "\uf1de"
                        color: Theme.primary
                        font.family: Theme.iconFontFamily
                        font.pixelSize: Theme.fontSizeMedium
                    }
                }

                Text {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    text: "Quick Settings"
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    font.weight: Theme.fontWeightBold
                    font.letterSpacing: 0.5
                }

                Rectangle {
                    width: 30
                    height: 30
                    radius: Theme.radiusSmall
                    color: settingsMouse.containsMouse 
                        ? Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.6)
                        : "transparent"
                    
                    Behavior on color {
                        ColorAnimation { duration: Theme.animationFast; easing.type: Theme.easingType }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "\uf013"
                        color: settingsMouse.containsMouse ? Theme.foreground : Theme.mutedForeground
                        font.family: Theme.iconFontFamily
                        font.pixelSize: Theme.fontSizeMedium
                        
                        Behavior on color {
                            ColorAnimation { duration: Theme.animationFast }
                        }
                        
                        rotation: settingsMouse.containsMouse ? 90 : 0
                        Behavior on rotation {
                            NumberAnimation { duration: Theme.animationNormal; easing.type: Easing.OutBack }
                        }
                    }

                    MouseArea {
                        id: settingsMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.openDetail("bar")
                    }
                }

                Rectangle {
                    width: 30
                    height: 30
                    radius: Theme.radiusSmall
                    color: closeMouse.containsMouse 
                        ? Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.15)
                        : "transparent"
                    
                    Behavior on color {
                        ColorAnimation { duration: Theme.animationFast; easing.type: Theme.easingType }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "\uf00d"
                        color: closeMouse.containsMouse ? Theme.error : Theme.mutedForeground
                        font.family: Theme.iconFontFamily
                        font.pixelSize: Theme.fontSizeMedium
                        
                        Behavior on color {
                            ColorAnimation { duration: Theme.animationFast }
                        }
                        
                        scale: closeMouse.pressed ? 0.85 : 1.0
                        Behavior on scale {
                            NumberAnimation { duration: 100 }
                        }
                    }

                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.closeRequested()
                    }
                }
            }
        }

        GridLayout {
            width: parent.width
            columns: 2
            columnSpacing: Theme.spacing.md
            rowSpacing: Theme.spacing.md

            Components.ToggleCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 62
                icon: "\uf1eb"
                title: "Wi-Fi"
                subtitle: !Services.Network.wifiEnabled ? "Disabled"
                    : Services.Network.wifiConnected && Services.Network.connectedWifiNetwork
                        ? Services.Network.connectedWifiNetwork.name
                        : Services.Network.wiredConnected ? "Ethernet" : "Enabled"
                active: Services.Network.wifiEnabled
                isEnabled: Services.Network.wifiHardwareEnabled
                onToggled: Services.Network.toggleWifi()
                onDetailClicked: root.openDetail("wifi")
            }

            Components.ToggleCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 62
                icon: "\uf293"
                title: "Bluetooth"
                subtitle: !Services.Bluetooth.available ? "Unavailable"
                    : !Services.Bluetooth.enabled ? "Disabled"
                    : Services.Bluetooth.connectedDeviceLabel.length > 0
                        ? Services.Bluetooth.connectedDeviceLabel : "Enabled"
                active: Services.Bluetooth.enabled
                isEnabled: Services.Bluetooth.available
                onToggled: Services.Bluetooth.toggle()
                onDetailClicked: root.openDetail("bluetooth")
            }

            Components.ToggleCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 62
                icon: "\uf06c"
                title: "Power profile"
                subtitle: Services.PowerProfiles.profileLabel(Services.PowerProfiles.profile)
                active: Services.PowerProfiles.profile === PowerProfile.PowerSaver
                onToggled: root.openDetail("power")
                onDetailClicked: root.openDetail("power")
            }

            Components.ToggleCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 62
                icon: "\uf186"
                title: "Night light"
                subtitle: Services.NightLight.enabled
                    ? Services.NightLight.temperature + "K" : "Off"
                active: Services.NightLight.enabled
                onToggled: Services.NightLight.toggle()
                onDetailClicked: root.openDetail("nightlight")
            }

            Components.ToggleCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 62
                icon: "\uf1f6"
                title: "Silent"
                subtitle: Services.Notifications.doNotDisturb ? "On" : "Off"
                active: Services.Notifications.doNotDisturb
                emphasis: true
                onToggled: Services.Notifications.toggleDnd()
                onDetailClicked: root.openDetail("dnd")
            }

            Components.ToggleCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 62
                icon: Services.Audio.sourceMuted ? "\uf131" : "\uf130"
                title: "Microphone"
                subtitle: Services.Audio.sourceMuted ? "Muted" : "Unmuted"
                active: Services.Audio.source !== null && !Services.Audio.sourceMuted
                isEnabled: Services.Audio.source !== null
                onToggled: Services.Audio.toggleSourceMute()
                onDetailClicked: root.openDetail("audio")
            }
        }

        // Enhanced audio/brightness panel with glass effect
        Rectangle {
            width: parent.width
            height: 90
            radius: Theme.radius
            color: Theme.panelSurface
            border.width: Theme.borderWidth
            border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.2)
            

            // Subtle gradient overlay
            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                opacity: 0.03
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Theme.primary }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            Column {
                anchors.fill: parent
                anchors.margins: Theme.spacing.lg
                spacing: Theme.spacing.lg

                Components.OverviewSliderRow {
                    width: parent.width
                    icon: Services.Audio.muted ? "\uf026" : "\uf028"
                    title: "Output volume"
                    detail: Services.Audio.sink
                        ? (Services.Audio.sink.description || Services.Audio.sink.nickname || Services.Audio.sink.name)
                        : ""
                    valueText: Services.Audio.sink
                        ? (Services.Audio.muted ? "Muted" : Services.Audio.volumePercent + "%")
                        : ""
                    value: Services.Audio.volume
                    from: 0
                    to: 1
                    isEnabled: Services.Audio.sink !== null
                    showDetail: true
                    onMoved: (value) => Services.Audio.setVolume(value)
                    onDetailClicked: root.openDetail("audio")
                }

                Components.OverviewSliderRow {
                    width: parent.width
                    icon: "\uf185"
                    title: "Brightness"
                    valueText: Services.Brightness.available
                        ? Services.Brightness.percent + "%" : "Unavailable"
                    value: Services.Brightness.percent / 100
                    from: 0
                    to: 1
                    isEnabled: Services.Brightness.available
                    onMoved: (value) => Services.Brightness.setPercent(value * 100)
                }
            }
        }

        MediaCard {
            width: parent.width
        }

        // Theme and Wallpaper cards with improved visuals
        RowLayout {
            width: parent.width
            height: 94
            spacing: Theme.spacing.md

            Rectangle {
                id: themeCard
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Theme.radius
                color: themeMouse.containsMouse ? Theme.panelSurfaceHover : Theme.panelSurface
                border.width: Theme.borderWidth
                border.color: themeMouse.containsMouse 
                    ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.4)
                    : Theme.subtleBorder

                Behavior on color {
                    ColorAnimation { duration: Theme.animationFast; easing.type: Theme.easingType }
                }
                
                Behavior on border.color {
                    ColorAnimation { duration: Theme.animationFast }
                }
                
                // Hover glow effect
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    opacity: themeMouse.containsMouse ? 0.08 : 0
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Theme.primary }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                    
                    Behavior on opacity {
                        NumberAnimation { duration: Theme.animationNormal }
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.spacing.lg
                    spacing: Theme.spacing.md

                    Rectangle {
                        Layout.preferredWidth: 52
                        Layout.preferredHeight: 52
                        Layout.alignment: Qt.AlignVCenter
                        radius: Theme.radius
                        color: Theme.surfaceElevated
                        border.width: Theme.borderWidth
                        border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3)

                        Grid {
                            anchors.centerIn: parent
                            columns: 2
                            spacing: 3

                            Repeater {
                                model: [
                                    Theme.colors.background,
                                    Theme.colors.surface,
                                    Theme.colors.primary,
                                    Theme.colors.secondary
                                ]

                                delegate: Rectangle {
                                    required property var modelData
                                    width: 20
                                    height: 20
                                    radius: 4
                                    color: modelData
                                    border.width: 1
                                    border.color: Qt.rgba(0, 0, 0, 0.15)
                                    
                                    scale: themeMouse.containsMouse ? 1.05 : 1.0
                                    Behavior on scale {
                                        NumberAnimation { duration: Theme.animationFast }
                                    }
                                }
                            }
                        }
                    }

                    Column {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 2

                        Text {
                            width: parent.width
                            text: "Theme"
                            color: Theme.mutedForeground
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Theme.fontWeightMedium
                        }

                        Text {
                            width: parent.width
                            text: ThemeManager.palette.name
                            color: Theme.foreground
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeBase
                            font.weight: Theme.fontWeightBold
                            elide: Text.ElideRight
                        }
                    }

                    Item {
                        Layout.alignment: Qt.AlignVCenter
                        Layout.preferredWidth: 16
                        Layout.preferredHeight: 16
                        
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            x: themeMouse.containsMouse ? parent.width - width + 2 : parent.width - width
                            text: "\uf054"
                            color: Theme.mutedForeground
                            font.family: Theme.iconFontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            
                            Behavior on x {
                                NumberAnimation { duration: Theme.animationFast }
                            }
                        }
                    }
                }

                MouseArea {
                    id: themeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.openDetail("theme")
                }
            }

            Rectangle {
                id: wallpaperCard
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Theme.radius
                color: wallpaperMouse.containsMouse ? Theme.panelSurfaceHover : Theme.panelSurface
                border.width: Theme.borderWidth
                border.color: wallpaperMouse.containsMouse 
                    ? Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.4)
                    : Theme.subtleBorder
                clip: true

                Behavior on color {
                    ColorAnimation { duration: Theme.animationFast; easing.type: Theme.easingType }
                }
                
                Behavior on border.color {
                    ColorAnimation { duration: Theme.animationFast }
                }
                
                // Hover glow effect
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    opacity: wallpaperMouse.containsMouse ? 0.08 : 0
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Theme.secondary }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                    
                    Behavior on opacity {
                        NumberAnimation { duration: Theme.animationNormal }
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.spacing.lg
                    spacing: Theme.spacing.md

                    Rectangle {
                        Layout.preferredWidth: 52
                        Layout.preferredHeight: 52
                        Layout.alignment: Qt.AlignVCenter
                        radius: Theme.radius
                        color: Theme.surfaceElevated
                        border.width: Theme.borderWidth
                        border.color: Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.3)
                        clip: true

                        Image {
                            anchors.fill: parent
                            source: Services.Wallpapers.currentPath.length > 0
                                ? "file://" + Services.Wallpapers.currentPath : ""
                            sourceSize.width: 104
                            sourceSize.height: 104
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: false
                            visible: Services.Wallpapers.currentPath.length > 0
                            
                            scale: wallpaperMouse.containsMouse ? 1.1 : 1.0
                            Behavior on scale {
                                NumberAnimation { duration: Theme.animationNormal }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: Services.Wallpapers.currentPath.length === 0
                            text: "\uf03e"
                            color: Theme.mutedForeground
                            font.family: Theme.iconFontFamily
                            font.pixelSize: Theme.fontSizeLarge
                        }
                    }

                    Column {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 2

                        Text {
                            width: parent.width
                            text: "Wallpaper"
                            color: Theme.mutedForeground
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Theme.fontWeightMedium
                        }

                        Text {
                            width: parent.width
                            text: Services.Wallpapers.name(Services.Wallpapers.currentPath) || "Not set"
                            color: Theme.foreground
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeBase
                            font.weight: Theme.fontWeightBold
                            elide: Text.ElideRight
                        }
                    }

                    Item {
                        Layout.alignment: Qt.AlignVCenter
                        Layout.preferredWidth: 16
                        Layout.preferredHeight: 16
                        
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            x: wallpaperMouse.containsMouse ? parent.width - width + 2 : parent.width - width
                            text: "\uf054"
                            color: Theme.mutedForeground
                            font.family: Theme.iconFontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            
                            Behavior on x {
                                NumberAnimation { duration: Theme.animationFast }
                            }
                        }
                    }
                }

                MouseArea {
                    id: wallpaperMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.openDetail("wallpaper")
                }
            }
        }

        // System status card with enhanced styling
        Rectangle {
            width: parent.width
            height: 68
            radius: Theme.radius
            color: Theme.panelSurface
            border.width: Theme.borderWidth
            border.color: Qt.rgba(root.batteryColor.r, root.batteryColor.g, root.batteryColor.b, 0.3)
            
            // Battery-based gradient accent
            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                opacity: 0.04
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: root.batteryColor }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.spacing.lg
                anchors.rightMargin: Theme.spacing.md
                spacing: Theme.spacing.lg

                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: batteryRow.implicitWidth

                    RowLayout {
                        id: batteryRow
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.spacing.md

                        Rectangle {
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 40
                            radius: Theme.radiusSmall
                            color: Qt.rgba(root.batteryColor.r, root.batteryColor.g, root.batteryColor.b, 0.15)
                            
                            Text {
                                anchors.centerIn: parent
                                text: Services.Battery.charging ? "\uf0e7"
                                    : !Services.Battery.available ? "\uf0e7"
                                    : Services.Battery.percentage >= 90 ? "\uf240"
                                    : Services.Battery.percentage >= 65 ? "\uf241"
                                    : Services.Battery.percentage >= 40 ? "\uf242"
                                    : Services.Battery.percentage >= 15 ? "\uf243"
                                    : "\uf244"
                                color: root.batteryColor
                                font.family: Theme.iconFontFamily
                                font.pixelSize: Theme.fontSizeLarge
                            }
                        }

                        Column {
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 2

                            Text {
                                text: Services.Battery.available
                                    ? Services.Battery.percentage + "%" : "AC power"
                                color: Theme.foreground
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                                font.weight: Theme.fontWeightBold
                            }

                            Text {
                                text: Services.Battery.available
                                    ? Services.Battery.stateLabel
                                        + (Services.Battery.timeLabel.length > 0
                                            ? " · " + Services.Battery.timeLabel : "")
                                    : "No battery detected"
                                color: Theme.mutedForeground
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.openDetail("battery")
                    }
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 32
                    color: Theme.subtleBorder
                }

                RowLayout {
                    spacing: Theme.spacing.sm

                    Rectangle {
                        width: 34
                        height: 34
                        radius: Theme.radiusSmall
                        color: lockMouse.containsMouse 
                            ? Qt.rgba(Theme.info.r, Theme.info.g, Theme.info.b, 0.15)
                            : "transparent"
                        
                        Behavior on color {
                            ColorAnimation { duration: Theme.animationFast }
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "\uf023"
                            color: lockMouse.containsMouse ? Theme.info : Theme.mutedForeground
                            font.family: Theme.iconFontFamily
                            font.pixelSize: Theme.fontSize
                            
                            scale: lockMouse.pressed ? 0.9 : 1.0
                            Behavior on scale {
                                NumberAnimation { duration: 100 }
                            }
                        }
                        
                        MouseArea {
                            id: lockMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Services.Session.lock()
                        }
                    }

                    Rectangle {
                        width: 34
                        height: 34
                        radius: Theme.radiusSmall
                        color: logoutMouse.containsMouse 
                            ? Qt.rgba(Theme.warning.r, Theme.warning.g, Theme.warning.b, 0.15)
                            : "transparent"
                        
                        Behavior on color {
                            ColorAnimation { duration: Theme.animationFast }
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "\uf2f5"
                            color: logoutMouse.containsMouse ? Theme.warning : Theme.mutedForeground
                            font.family: Theme.iconFontFamily
                            font.pixelSize: Theme.fontSize
                            
                            scale: logoutMouse.pressed ? 0.9 : 1.0
                            Behavior on scale {
                                NumberAnimation { duration: 100 }
                            }
                        }
                        
                        MouseArea {
                            id: logoutMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Services.Session.logout()
                        }
                    }

                    Rectangle {
                        width: 34
                        height: 34
                        radius: Theme.radiusSmall
                        color: powerMouse.containsMouse 
                            ? Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.2)
                            : "transparent"
                        
                        Behavior on color {
                            ColorAnimation { duration: Theme.animationFast }
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "\uf011"
                            color: Theme.error
                            font.family: Theme.iconFontFamily
                            font.pixelSize: Theme.fontSize
                            
                            scale: powerMouse.pressed ? 0.9 : 1.0
                            Behavior on scale {
                                NumberAnimation { duration: 100 }
                            }
                        }
                        
                        MouseArea {
                            id: powerMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.powerRequested()
                        }
                    }
                }
            }
        }
    }
}
