import QtQuick
import QtQuick.Layouts
import "../../../themes"
import "../../../config" as Config
import "../../../components" as Components

Components.SettingsPage {
    id: page

    title: "Control Center"
    icon: "\uf1de"
    description: "Control the quick settings dashboard: columns, size, spacing and widget visibility."

    function widgetTitle(id) {
        if (id === "wifi") return "Wi-Fi";
        if (id === "bluetooth") return "Bluetooth";
        if (id === "power") return "Power profile";
        if (id === "nightlight") return "Night light";
        if (id === "dnd") return "Do Not Disturb";
        if (id === "microphone") return "Microphone";
        return id;
    }

    Components.SettingsCard {
        title: "Layout"

        Components.SettingsChoiceRow {
            title: "Columns"
            description: "Two columns fit the default width; three columns need a wider panel."
            options: [
                { id: "2", label: "2 columns" },
                { id: "3", label: "3 columns" }
            ]
            current: String(Config.Settings.controlCenterColumns)
            onSelected: (id) => {
                Config.Settings.controlCenterColumns = Number(id) === 3 ? 3 : 2;
                Config.Settings.scheduleSave();
            }
        }

        Components.SettingsSliderRow {
            title: "Panel width"
            valueText: Config.Settings.controlCenterWidth + " px"
            value: Config.Settings.controlCenterWidth
            from: 360
            to: 680
            onMoved: (value) => {
                Config.Settings.controlCenterWidth = Math.round(value);
                Config.Settings.scheduleSave();
            }
        }

        Components.SettingsSliderRow {
            title: "Card spacing"
            valueText: Config.Settings.controlCenterSpacing + " px"
            value: Config.Settings.controlCenterSpacing
            from: 4
            to: 24
            onMoved: (value) => {
                Config.Settings.controlCenterSpacing = Math.round(value);
                Config.Settings.scheduleSave();
            }
        }
    }

    Components.SettingsCard {
        title: "Quick cards"
        description: "Reorder the quick cards and choose which ones appear in the overview."

        Repeater {
            model: Config.Settings.controlCenterWidgets

            delegate: RowLayout {
                required property var modelData
                required property int index

                width: parent.width
                height: Theme.rowHeight
                spacing: Theme.spacing.sm

                Text {
                    Layout.fillWidth: true
                    text: page.widgetTitle(modelData.id)
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeBase
                }

                Components.SettingsButton {
                    Layout.alignment: Qt.AlignVCenter
                    icon: "\uf077"
                    isEnabled: index > 0
                    onClicked: Config.Settings.moveControlCenterWidget(index, index - 1)
                }

                Components.SettingsButton {
                    Layout.alignment: Qt.AlignVCenter
                    icon: "\uf078"
                    isEnabled: index < Config.Settings.controlCenterWidgets.length - 1
                    onClicked: Config.Settings.moveControlCenterWidget(index, index + 1)
                }

                Components.ToggleSwitch {
                    Layout.alignment: Qt.AlignVCenter
                    checked: modelData.visible
                    onToggled: Config.Settings.setControlCenterWidgetVisible(
                        modelData.id, !modelData.visible)
                }
            }
        }
    }

    Components.SettingsCard {
        title: "Sections"

        Components.SettingsToggleRow {
            title: "Media player"
            checked: Config.Settings.controlCenterShowMedia
            onToggled: {
                Config.Settings.controlCenterShowMedia = !Config.Settings.controlCenterShowMedia;
                Config.Settings.scheduleSave();
            }
        }

        Components.SettingsToggleRow {
            title: "Volume and brightness sliders"
            checked: Config.Settings.controlCenterShowSliders
            onToggled: {
                Config.Settings.controlCenterShowSliders = !Config.Settings.controlCenterShowSliders;
                Config.Settings.scheduleSave();
            }
        }

        Components.SettingsToggleRow {
            title: "Theme and wallpaper cards"
            checked: Config.Settings.controlCenterShowThemeWallpaper
            onToggled: {
                Config.Settings.controlCenterShowThemeWallpaper = !Config.Settings.controlCenterShowThemeWallpaper;
                Config.Settings.scheduleSave();
            }
        }

        Components.SettingsButton {
            text: "Reset control center"
            icon: "\uf2ea"
            onClicked: Config.Settings.resetControlCenter()
        }
    }
}
