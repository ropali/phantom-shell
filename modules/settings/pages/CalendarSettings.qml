import QtQuick
import "../../../themes"
import "../../../config" as Config
import "../../../components" as Components

Components.SettingsPage {
    title: "Calendar"
    icon: "\uf073"
    description: "Configure the calendar flyout opened from the bar clock."

    Components.SettingsCard {
        title: "Week"

        Components.SettingsChoiceRow {
            title: "First day of the week"
            options: [
                { id: "0", label: "Sunday" },
                { id: "1", label: "Monday" }
            ]
            current: String(Config.Settings.calendarFirstDay)
            onSelected: (id) => {
                Config.Settings.calendarFirstDay = Number(id) === 0 ? 0 : 1;
                Config.Settings.scheduleSave();
            }
        }

        Components.SettingsToggleRow {
            title: "Show week numbers"
            checked: Config.Settings.calendarShowWeekNumbers
            onToggled: {
                Config.Settings.calendarShowWeekNumbers = !Config.Settings.calendarShowWeekNumbers;
                Config.Settings.scheduleSave();
            }
        }

        Components.SettingsToggleRow {
            title: "Show adjacent month dates"
            description: "Dimmed dates from the previous and next months."
            checked: Config.Settings.calendarShowAdjacentMonths
            onToggled: {
                Config.Settings.calendarShowAdjacentMonths = !Config.Settings.calendarShowAdjacentMonths;
                Config.Settings.scheduleSave();
            }
        }

        Components.SettingsToggleRow {
            title: "Highlight today"
            checked: Config.Settings.calendarHighlightToday
            onToggled: {
                Config.Settings.calendarHighlightToday = !Config.Settings.calendarHighlightToday;
                Config.Settings.scheduleSave();
            }
        }
    }

    Components.SettingsCard {
        title: "Content"

        Components.SettingsToggleRow {
            title: "Show weather"
            description: "Display current conditions in the calendar header."
            checked: Config.Settings.calendarShowWeather
            onToggled: {
                Config.Settings.calendarShowWeather = !Config.Settings.calendarShowWeather;
                Config.Settings.scheduleSave();
            }
        }
    }

    Components.SettingsCard {
        title: "Size"

        Components.SettingsSliderRow {
            title: "Calendar width"
            valueText: Config.Settings.calendarWidth + " px"
            value: Config.Settings.calendarWidth
            from: 340
            to: 640
            onMoved: (value) => {
                Config.Settings.calendarWidth = Math.round(value);
                Config.Settings.scheduleSave();
            }
        }

        Components.SettingsSliderRow {
            title: "Date cell height"
            valueText: Config.Settings.calendarCellHeight + " px"
            value: Config.Settings.calendarCellHeight
            from: 28
            to: 48
            onMoved: (value) => {
                Config.Settings.calendarCellHeight = Math.round(value);
                Config.Settings.scheduleSave();
            }
        }

        Components.SettingsButton {
            text: "Reset calendar"
            icon: "\uf2ea"
            onClicked: Config.Settings.resetCalendar()
        }
    }
}
