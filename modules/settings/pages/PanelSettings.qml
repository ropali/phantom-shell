import QtQuick
import QtQuick.Layouts
import "../../../themes"
import "../../../config" as Config
import "../../../components" as Components

Components.SettingsPage {
    id: page

    title: "Panel"
    icon: "\uf0c9"
    description: "Configure the Phantom status bar, its geometry and the modules it displays."

    function barTitle(id) {
        if (id === "notifications") return "Notifications";
        if (id === "network") return "Network";
        if (id === "bluetooth") return "Bluetooth";
        if (id === "audio") return "Volume";
        if (id === "power") return "Power";
        return id;
    }

    function barDescription(id) {
        if (id === "notifications") return "Notification center and Do Not Disturb";
        if (id === "network") return "Wi-Fi and Ethernet status";
        if (id === "bluetooth") return "Adapter and device status";
        if (id === "audio") return "Output volume and audio devices";
        if (id === "power") return "Session and power menu";
        return "";
    }

    Components.SettingsCard {
        title: "General"

        Components.SettingsToggleRow {
            title: "Show status bar"
            description: "Hide the bar without losing its module configuration."
            checked: Config.Settings.barVisible
            onToggled: Config.Settings.setBarVisible(!Config.Settings.barVisible)
        }

        Components.SettingsChoiceRow {
            title: "Bar style"
            description: "Classic is one continuous bar; Pills uses floating groups."
            options: [
                { id: "classic", label: "Classic" },
                { id: "pills", label: "Pills" }
            ]
            current: Config.Settings.barStyle
            onSelected: (id) => Config.Settings.setBarStyle(id)
        }

        Components.SettingsChoiceRow {
            title: "Position"
            description: "Place the bar at the top or bottom of the screen."
            options: [
                { id: "top", label: "Top" },
                { id: "bottom", label: "Bottom" }
            ]
            current: Config.Settings.barPosition
            onSelected: (id) => Config.Settings.setBarPosition(id)
        }

        Components.SettingsChoiceRow {
            title: "Horizontal alignment"
            description: "Only applies to the Classic bar. Pills always span the screen."
            options: [
                { id: "left", label: "Left" },
                { id: "center", label: "Center" },
                { id: "right", label: "Right" }
            ]
            current: Config.Settings.barAlignment
            onSelected: (id) => Config.Settings.setBarAlignment(id)
        }

        Components.SettingsChoiceRow {
            title: "Control center group"
            description: "Move the tray, controls and control center button to the left or right."
            visible: Config.Settings.barStyle === "classic"
            options: [
                { id: "left", label: "Left" },
                { id: "right", label: "Right" }
            ]
            current: Config.Settings.barControlCenterPosition
            onSelected: (id) => Config.Settings.setBarControlCenterPosition(id)
        }
    }

    Components.SettingsCard {
        title: "Dimensions"

        Components.SettingsSliderRow {
            title: "Bar height"
            valueText: Config.Settings.barHeight + " px"
            value: Config.Settings.barHeight
            from: 24
            to: 64
            onMoved: (value) => Config.Settings.setBarHeight(value)
        }

        Components.SettingsSliderRow {
            title: "Bar width"
            description: "Percentage of the monitor width used by the Classic bar."
            valueText: Config.Settings.barWidthPercent + "%"
            value: Config.Settings.barWidthPercent
            from: 20
            to: 100
            onMoved: (value) => Config.Settings.setBarWidthPercent(value)
        }

        Components.SettingsSliderRow {
            title: "Screen edge gap"
            description: "Minimum space between the bar and the left and right edges."
            valueText: Config.Settings.edgeGap + " px"
            value: Config.Settings.edgeGap
            from: 0
            to: 200
            onMoved: (value) => Config.Settings.setEdgeGap(value)
        }

        Components.SettingsSliderRow {
            title: "Screen margin"
            description: "Space between the bar and the physical screen edge."
            valueText: Config.Settings.screenMargin + " px"
            value: Config.Settings.screenMargin
            from: 0
            to: 32
            onMoved: (value) => Config.Settings.setScreenMargin(value)
        }

        Components.SettingsSliderRow {
            title: "Window gap"
            description: "Reserved space between the bar and tiled windows."
            valueText: Config.Settings.barWindowGap + " px"
            value: Config.Settings.barWindowGap
            from: 0
            to: 48
            onMoved: (value) => Config.Settings.setBarWindowGap(value)
        }
    }

    Components.SettingsCard {
        title: "Modules"
        description: "Choose which controls appear in the bar. Drag the icons on the bar or use the arrows here to reorder them."

        Repeater {
            model: Config.Settings.barLayout

            delegate: RowLayout {
                required property var modelData
                required property int index

                width: parent.width
                height: Math.max(Theme.rowHeight, moduleColumn.implicitHeight + Theme.spacing.md)
                spacing: Theme.spacing.sm

                Column {
                    id: moduleColumn
                    Layout.fillWidth: true
                    spacing: 1

                    Text {
                        width: parent.width
                        text: page.barTitle(modelData.id)
                        color: Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeBase
                        font.weight: Theme.fontWeightMedium
                    }

                    Text {
                        width: parent.width
                        text: page.barDescription(modelData.id)
                        color: Theme.mutedForeground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        elide: Text.ElideRight
                    }
                }

                Components.SettingsButton {
                    Layout.alignment: Qt.AlignVCenter
                    icon: "\uf077"
                    isEnabled: index > 0
                    onClicked: Config.Settings.moveBarItem(index, index - 1)
                }

                Components.SettingsButton {
                    Layout.alignment: Qt.AlignVCenter
                    icon: "\uf078"
                    isEnabled: index < Config.Settings.barLayout.length - 1
                    onClicked: Config.Settings.moveBarItem(index, index + 1)
                }

                Components.ToggleSwitch {
                    Layout.alignment: Qt.AlignVCenter
                    checked: modelData.visible
                    onToggled: Config.Settings.setBarItemVisible(modelData.id, !modelData.visible)
                }
            }
        }

        Components.SettingsButton {
            text: "Reset status bar settings"
            icon: "\uf2ea"
            destructive: true
            onClicked: Config.Settings.resetPanel()
        }
    }
}
