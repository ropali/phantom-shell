import QtQuick
import Quickshell
import "../../config" as Config
import "../../themes"
import "../../services" as Services

BarPill {
    id: root

    readonly property bool dateFirst: Config.Settings.dateTimeOrder === "date-first"
    readonly property bool needsSeconds: Config.Settings.clockShowSeconds
        || Config.Settings.timeFormatOverride.indexOf("s") !== -1

    interactive: true
    contentSpacing: Theme.spacing.md
    visible: Config.Settings.clockShow || Config.Settings.dateShow

    SystemClock {
        id: clock
        enabled: true
        precision: root.needsSeconds ? SystemClock.Seconds : SystemClock.Minutes
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "\uf017"
        color: Theme.primary
        font.family: Theme.iconFontFamily
        font.pixelSize: Theme.fontSizeSmall
    }

    Loader {
        anchors.verticalCenter: parent.verticalCenter
        visible: root.dateFirst ? Config.Settings.dateShow : Config.Settings.clockShow
        sourceComponent: root.dateFirst ? dateTextComponent : timeTextComponent
    }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        visible: Config.Settings.dateShow && Config.Settings.clockShow
        width: 1
        height: Theme.controlHeight - Theme.spacing.lg
        color: Theme.subtleBorder
    }

    Loader {
        anchors.verticalCenter: parent.verticalCenter
        visible: root.dateFirst ? Config.Settings.clockShow : Config.Settings.dateShow
        sourceComponent: root.dateFirst ? timeTextComponent : dateTextComponent
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

    Component {
        id: dateTextComponent

        Text {
            text: Qt.formatDateTime(clock.date, Config.Settings.dateFormat)
            color: Theme.mutedForeground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
        }
    }

    Component {
        id: timeTextComponent

        Text {
            text: Qt.formatDateTime(clock.date, Config.Settings.timeFormat)
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Theme.fontWeightBold
        }
    }
}
