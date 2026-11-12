import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../themes"
import "../../../config" as Config
import "../../../components" as Components

Components.SettingsPage {
    id: page

    title: "Date & Time"
    icon: "\uf017"
    description: "Control the clock and date shown in the status bar and calendar."

    SystemClock {
        id: previewClock
        enabled: true
        precision: SystemClock.Seconds
    }

    Components.SettingsCard {
        title: "Preview"

        Rectangle {
            width: parent.width
            height: 72
            radius: Theme.radius
            color: Theme.surface
            border.width: Theme.borderWidth
            border.color: Theme.subtleBorder

            Row {
                anchors.centerIn: parent
                spacing: Theme.spacing.md

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: Config.Settings.dateShow
                    text: Qt.formatDateTime(previewClock.date, Config.Settings.dateFormat)
                    color: Theme.mutedForeground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: Config.Settings.dateShow && Config.Settings.clockShow
                    width: 1
                    height: 24
                    color: Theme.border
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: Config.Settings.clockShow
                    text: Qt.formatDateTime(previewClock.date, Config.Settings.timeFormat)
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    font.weight: Theme.fontWeightBold
                }
            }
        }
    }

    Components.SettingsCard {
        title: "Clock"

        Components.SettingsToggleRow {
            title: "Show clock"
            checked: Config.Settings.clockShow
            onToggled: {
                Config.Settings.clockShow = !Config.Settings.clockShow;
                Config.Settings.scheduleSave();
            }
        }

        Components.SettingsToggleRow {
            title: "24-hour time"
            checked: Config.Settings.clockUse24Hour
            onToggled: {
                Config.Settings.clockUse24Hour = !Config.Settings.clockUse24Hour;
                Config.Settings.scheduleSave();
            }
        }

        Components.SettingsToggleRow {
            title: "Show seconds"
            checked: Config.Settings.clockShowSeconds
            onToggled: {
                Config.Settings.clockShowSeconds = !Config.Settings.clockShowSeconds;
                Config.Settings.scheduleSave();
            }
        }

        Components.SettingsToggleRow {
            title: "Show AM/PM"
            isEnabled: !Config.Settings.clockUse24Hour
            checked: Config.Settings.clockShowAmPm
            onToggled: {
                Config.Settings.clockShowAmPm = !Config.Settings.clockShowAmPm;
                Config.Settings.scheduleSave();
            }
        }

        RowLayout {
            width: parent.width
            spacing: Theme.spacing.sm

            Components.SettingsTextField {
                Layout.fillWidth: true
                value: Config.Settings.timeFormatOverride
                placeholder: "Custom time format (optional)"
                onEdited: (text) => {
                    Config.Settings.timeFormatOverride = text;
                    Config.Settings.scheduleSave();
                }
            }

            Components.SettingsButton {
                text: "Clear"
                onClicked: {
                    Config.Settings.timeFormatOverride = "";
                    Config.Settings.scheduleSave();
                }
            }
        }
    }

    Components.SettingsCard {
        title: "Date"

        Components.SettingsToggleRow {
            title: "Show date"
            checked: Config.Settings.dateShow
            onToggled: {
                Config.Settings.dateShow = !Config.Settings.dateShow;
                Config.Settings.scheduleSave();
            }
        }

        Components.SettingsToggleRow {
            title: "Show weekday"
            checked: Config.Settings.dateShowWeekday
            onToggled: {
                Config.Settings.dateShowWeekday = !Config.Settings.dateShowWeekday;
                Config.Settings.scheduleSave();
            }
        }

        Components.SettingsToggleRow {
            title: "Show year"
            checked: Config.Settings.dateShowYear
            onToggled: {
                Config.Settings.dateShowYear = !Config.Settings.dateShowYear;
                Config.Settings.scheduleSave();
            }
        }

        RowLayout {
            width: parent.width
            spacing: Theme.spacing.sm

            Components.SettingsTextField {
                Layout.fillWidth: true
                value: Config.Settings.dateFormatOverride
                placeholder: "Custom date format (optional)"
                onEdited: (text) => {
                    Config.Settings.dateFormatOverride = text;
                    Config.Settings.scheduleSave();
                }
            }

            Components.SettingsButton {
                text: "Clear"
                onClicked: {
                    Config.Settings.dateFormatOverride = "";
                    Config.Settings.scheduleSave();
                }
            }
        }
    }

    Components.SettingsCard {
        title: "Ordering"

        Components.SettingsChoiceRow {
            title: "Date and time order"
            options: [
                { id: "date-first", label: "Date first" },
                { id: "time-first", label: "Time first" }
            ]
            current: Config.Settings.dateTimeOrder
            onSelected: (id) => {
                Config.Settings.dateTimeOrder = id;
                Config.Settings.scheduleSave();
            }
        }

        Components.SettingsButton {
            text: "Reset date and time"
            icon: "\uf2ea"
            onClicked: Config.Settings.resetDateTime()
        }
    }
}
