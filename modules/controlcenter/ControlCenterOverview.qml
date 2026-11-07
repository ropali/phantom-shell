import QtQuick
import QtQuick.Layouts
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

    implicitHeight: content.implicitHeight + Theme.spacing.lg * 2

    Column {
        id: content
        anchors.fill: parent
        anchors.margins: Theme.spacing.lg
        spacing: Theme.spacing.lg

        RowLayout {
            width: parent.width
            height: 28
            spacing: Theme.spacing.md

            Text {
                Layout.alignment: Qt.AlignVCenter
                text: "\uf1de"
                color: Theme.primary
                font.family: Theme.iconFontFamily
                font.pixelSize: Theme.fontSizeMedium
            }

            Text {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                text: "Quick settings"
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                font.weight: Theme.fontWeightBold
            }

            Item {
                width: 26
                height: 26

                Text {
                    anchors.centerIn: parent
                    text: "\uf013"
                    color: settingsMouse.containsMouse ? Theme.foreground : Theme.mutedForeground
                    font.family: Theme.iconFontFamily
                    font.pixelSize: Theme.fontSizeMedium
                }

                MouseArea {
                    id: settingsMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.openDetail("bar")
                }
            }

            Item {
                width: 26
                height: 26

                Text {
                    anchors.centerIn: parent
                    text: "\uf00d"
                    color: closeMouse.containsMouse ? Theme.foreground : Theme.mutedForeground
                    font.family: Theme.iconFontFamily
                    font.pixelSize: Theme.fontSizeMedium
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

        Rectangle {
            width: parent.width
            height: 76
            radius: Theme.radiusSmall
            color: Theme.panelSurface
            border.width: Theme.borderWidth
            border.color: Theme.subtleBorder

            Column {
                anchors.fill: parent
                anchors.margins: Theme.spacing.lg
                spacing: Theme.spacing.md

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

        RowLayout {
            width: parent.width
            height: 84
            spacing: Theme.spacing.md

            Rectangle {
                id: themeCard
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Theme.radiusSmall
                color: themeMouse.containsMouse ? Theme.panelSurfaceHover : Theme.panelSurface
                border.width: Theme.borderWidth
                border.color: Theme.subtleBorder

                Behavior on color {
                    ColorAnimation { duration: Theme.animationFast; easing.type: Theme.easingType }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.spacing.md + Theme.spacing.xs
                    spacing: Theme.spacing.md

                    Rectangle {
                        Layout.preferredWidth: 44
                        Layout.preferredHeight: 44
                        Layout.alignment: Qt.AlignVCenter
                        radius: Theme.radiusSmall
                        color: Theme.surfaceElevated

                        Grid {
                            anchors.centerIn: parent
                            columns: 2
                            spacing: 2

                            Repeater {
                                model: [
                                    Theme.colors.background,
                                    Theme.colors.surface,
                                    Theme.colors.primary,
                                    Theme.colors.secondary
                                ]

                                delegate: Rectangle {
                                    required property var modelData
                                    width: 18
                                    height: 18
                                    radius: 3
                                    color: modelData
                                    border.width: Theme.borderWidth
                                    border.color: Theme.subtleBorder
                                }
                            }
                        }
                    }

                    Column {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 1

                        Text {
                            width: parent.width
                            text: "Theme"
                            color: Theme.mutedForeground
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
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

                    Text {
                        Layout.alignment: Qt.AlignVCenter
                        text: "\uf054"
                        color: Theme.mutedForeground
                        font.family: Theme.iconFontFamily
                        font.pixelSize: Theme.fontSizeSmall
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
                radius: Theme.radiusSmall
                color: wallpaperMouse.containsMouse ? Theme.panelSurfaceHover : Theme.panelSurface
                border.width: Theme.borderWidth
                border.color: Theme.subtleBorder
                clip: true

                Behavior on color {
                    ColorAnimation { duration: Theme.animationFast; easing.type: Theme.easingType }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.spacing.md + Theme.spacing.xs
                    spacing: Theme.spacing.md

                    Rectangle {
                        Layout.preferredWidth: 44
                        Layout.preferredHeight: 44
                        Layout.alignment: Qt.AlignVCenter
                        radius: Theme.radiusSmall
                        color: Theme.surfaceElevated
                        clip: true

                        Image {
                            anchors.fill: parent
                            source: Services.Wallpapers.currentPath.length > 0
                                ? "file://" + Services.Wallpapers.currentPath : ""
                            sourceSize.width: 88
                            sourceSize.height: 88
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: false
                            visible: Services.Wallpapers.currentPath.length > 0
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: Services.Wallpapers.currentPath.length === 0
                            text: "\uf03e"
                            color: Theme.mutedForeground
                            font.family: Theme.iconFontFamily
                            font.pixelSize: Theme.fontSizeMedium
                        }
                    }

                    Column {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 1

                        Text {
                            width: parent.width
                            text: "Wallpaper"
                            color: Theme.mutedForeground
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
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

                    Text {
                        Layout.alignment: Qt.AlignVCenter
                        text: "\uf054"
                        color: Theme.mutedForeground
                        font.family: Theme.iconFontFamily
                        font.pixelSize: Theme.fontSizeSmall
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

        Rectangle {
            width: parent.width
            height: 60
            radius: Theme.radiusSmall
            color: Theme.panelSurface
            border.width: Theme.borderWidth
            border.color: Theme.subtleBorder

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.spacing.lg
                anchors.rightMargin: Theme.spacing.sm
                spacing: Theme.spacing.md

                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: batteryRow.implicitWidth

                    RowLayout {
                        id: batteryRow
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.spacing.sm

                        Text {
                            Layout.alignment: Qt.AlignVCenter
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

                        Column {
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 0

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
                    Layout.preferredHeight: 28
                    color: Theme.subtleBorder
                }

                RowLayout {
                    spacing: Theme.spacing.sm

                    Components.IconButton {
                        buttonSize: 30
                        iconSize: Theme.fontSize
                        icon: "\uf023"
                        tooltip: "Lock"
                        onClicked: Services.Session.lock()
                    }

                    Components.IconButton {
                        buttonSize: 30
                        iconSize: Theme.fontSize
                        icon: "\uf2f5"
                        tooltip: "Logout"
                        onClicked: Services.Session.logout()
                    }

                    Components.IconButton {
                        buttonSize: 30
                        iconSize: Theme.fontSize
                        icon: "\uf011"
                        iconColor: Theme.error
                        tooltip: "Power menu"
                        onClicked: root.powerRequested()
                    }
                }
            }
        }
    }
}
