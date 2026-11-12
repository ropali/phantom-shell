import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../../themes"
import "../../../config" as Config
import "../../../components" as Components

Components.SettingsPage {
    id: page

    title: "Advanced"
    icon: "\uf085"
    description: "Window sizing, diagnostics, configuration paths and reset tools."

    property string quickshellVersion: "Unknown"
    property bool confirmingReset: false

    Process {
        id: versionProcess
        command: ["qs", "--version"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: page.quickshellVersion = text.trim()
        }
    }

    Components.SettingsCard {
        title: "Settings window"

        Components.SettingsSliderRow {
            title: "Window width"
            valueText: Config.Settings.settingsWidth + " px"
            value: Config.Settings.settingsWidth
            from: 720
            to: 1600
            onMoved: (value) => {
                Config.Settings.settingsWidth = Math.round(value);
                Config.Settings.scheduleSave();
            }
        }

        Components.SettingsSliderRow {
            title: "Window height"
            valueText: Config.Settings.settingsHeight + " px"
            value: Config.Settings.settingsHeight
            from: 520
            to: 1100
            onMoved: (value) => {
                Config.Settings.settingsHeight = Math.round(value);
                Config.Settings.scheduleSave();
            }
        }

        Components.SettingsSliderRow {
            title: "Sidebar width"
            valueText: Config.Settings.settingsSidebarPercent + "%"
            value: Config.Settings.settingsSidebarPercent
            from: 22
            to: 42
            onMoved: (value) => {
                Config.Settings.settingsSidebarPercent = Math.round(value);
                Config.Settings.scheduleSave();
            }
        }
    }

    Components.SettingsCard {
        title: "Diagnostics"

        Components.SettingsInfoRow {
            label: "Phantom"
            value: "Development build"
        }

        Components.SettingsInfoRow {
            label: "Quickshell"
            value: page.quickshellVersion
        }

        Components.SettingsInfoRow {
            label: "Shell directory"
            value: Quickshell.shellDir
        }

        Components.SettingsInfoRow {
            label: "Bar state"
            value: Config.Settings.barStatePath
        }

        Components.SettingsInfoRow {
            label: "Settings state"
            value: Config.Settings.settingsStatePath
        }

        Components.SettingsInfoRow {
            label: "Theme state"
            value: ThemeManager.statePath
        }
    }

    Components.SettingsCard {
        title: "Reset categories"
        description: "Restore one category at a time. The active theme is managed separately."

        Flow {
            width: parent.width
            spacing: Theme.spacing.sm

            Components.SettingsButton {
                text: "Panel"
                onClicked: Config.Settings.resetPanel()
            }

            Components.SettingsButton {
                text: "Appearance"
                onClicked: Config.Settings.resetAppearance()
            }

            Components.SettingsButton {
                text: "Date & Time"
                onClicked: Config.Settings.resetDateTime()
            }

            Components.SettingsButton {
                text: "Calendar"
                onClicked: Config.Settings.resetCalendar()
            }

            Components.SettingsButton {
                text: "Control Center"
                onClicked: Config.Settings.resetControlCenter()
            }

            Components.SettingsButton {
                text: "Wallpaper"
                onClicked: Config.Settings.resetWallpaper()
            }

            Components.SettingsButton {
                text: "Window"
                onClicked: Config.Settings.resetWindow()
            }
        }
    }

    Components.SettingsCard {
        title: "Reset everything"
        description: "This restores the default layout, appearance overrides, clock, calendar, control center, wallpaper and window settings. Theme selection is reset to the default theme."

        Column {
            width: parent.width
            spacing: Theme.spacing.sm

            Components.SettingsButton {
                visible: !page.confirmingReset
                text: "Reset all Phantom settings"
                icon: "\uf2ea"
                destructive: true
                onClicked: page.confirmingReset = true
            }

            RowLayout {
                width: parent.width
                visible: page.confirmingReset
                spacing: Theme.spacing.sm

                Text {
                    Layout.fillWidth: true
                    text: "Reset every Phantom setting? This cannot be undone."
                    color: Theme.error
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    wrapMode: Text.WordWrap
                }

                Components.SettingsButton {
                    text: "Cancel"
                    onClicked: page.confirmingReset = false
                }

                Components.SettingsButton {
                    text: "Reset"
                    destructive: true
                    onClicked: {
                        Config.Settings.resetAll();
                        ThemeManager.applyTheme(ThemeManager.defaultThemeId);
                        page.confirmingReset = false;
                    }
                }
            }
        }
    }
}
