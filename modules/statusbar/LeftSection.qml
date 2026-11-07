import QtQuick
import Quickshell
import "../../config" as Config
import "../../themes"
import "../../services" as Services

Item {
    id: root

    implicitWidth: row.implicitWidth
    implicitHeight: Config.Settings.barHeight

    SystemClock {
        id: clock
        enabled: true
        precision: SystemClock.Minutes
    }

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacing.md

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatDateTime(clock.date, Config.Settings.dateFormat)
            color: Theme.mutedForeground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 1
            height: Theme.controlHeight - Theme.spacing.xl - Theme.spacing.sm
            color: Theme.border
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatDateTime(clock.date, Config.Settings.timeFormat)
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Theme.fontWeightBold
        }
    }

    MouseArea {
        id: mouseArea
        anchors.centerIn: parent
        width: parent.width + 16
        height: parent.height
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            const wasOpen = calendar.shown;
            Services.UiState.dismissAll();
            calendar.shown = !wasOpen;
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: -Theme.spacing.xs
        anchors.rightMargin: -Theme.spacing.xs
        anchors.topMargin: Theme.spacing.xs
        anchors.bottomMargin: Theme.spacing.xs
        radius: Theme.radiusSmall
        color: mouseArea.containsMouse ? Theme.surface : "transparent"
        z: -1

        Behavior on color {
            ColorAnimation { duration: Theme.animationFast; easing.type: Theme.easingType }
        }
    }

    CalendarPopup {
        id: calendar
        anchorItem: root
    }
}
