import QtQuick
import Quickshell
import "../../config" as Config
import "../../themes"
import "../../services" as Services

BarPill {
    id: root

    interactive: true
    contentSpacing: Theme.spacing.md

    SystemClock {
        id: clock
        enabled: true
        precision: SystemClock.Minutes
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "\uf017"
        color: Theme.primary
        font.family: Theme.iconFontFamily
        font.pixelSize: Theme.fontSizeSmall
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: Qt.formatDateTime(clock.date, Config.Settings.timeFormat)
        color: Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.weight: Theme.fontWeightBold
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "·"
        color: Theme.mutedForeground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: Qt.formatDateTime(clock.date, Config.Settings.dateFormat)
        color: Theme.mutedForeground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
    }

    CalendarPopup {
        id: calendar
        anchorItem: root
    }

    onClicked: {
        const wasOpen = calendar.shown;
        Services.UiState.dismissAll();
        calendar.shown = !wasOpen;
    }
}
