import QtQuick
import Quickshell
import "../../config" as Config
import "../../themes"
import "../../services" as Services

Item {
    id: root

    property var controller: null
    property alias groupSlot: leftGroupSlot

    readonly property bool dateFirst: Config.Settings.dateTimeOrder === "date-first"
    readonly property bool needsSeconds: Config.Settings.clockShowSeconds
        || Config.Settings.timeFormatOverride.indexOf("s") !== -1

    implicitWidth: row.implicitWidth
    implicitHeight: Config.Settings.barHeight

    SystemClock {
        id: clock
        enabled: true
        precision: root.needsSeconds ? SystemClock.Seconds : SystemClock.Minutes
    }

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacing.md

        Item {
            id: leftGroupSlot
            width: childrenRect.width
            height: Config.Settings.barHeight
        }

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            visible: Config.Settings.barControlCenterPosition === "left"
            width: visible ? 1 : 0
            height: Theme.controlHeight - Theme.spacing.xl - Theme.spacing.sm
            color: Theme.border
        }

        Item {
            id: clockArea
            width: clockRow.implicitWidth
            height: Config.Settings.barHeight
            visible: Config.Settings.dateShow || Config.Settings.clockShow

            Row {
                id: clockRow
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.spacing.md

                Loader {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.dateFirst ? Config.Settings.dateShow : Config.Settings.clockShow
                    sourceComponent: root.dateFirst ? dateTextComponent : timeTextComponent
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: Config.Settings.dateShow && Config.Settings.clockShow
                    width: 1
                    height: Theme.controlHeight - Theme.spacing.xl - Theme.spacing.sm
                    color: Theme.border
                }

                Loader {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.dateFirst ? Config.Settings.clockShow : Config.Settings.dateShow
                    sourceComponent: root.dateFirst ? timeTextComponent : dateTextComponent
                }
            }

            Rectangle {
                anchors.fill: parent
                anchors.leftMargin: -Theme.spacing.xs
                anchors.rightMargin: -Theme.spacing.xs
                anchors.topMargin: Theme.spacing.xs
                anchors.bottomMargin: Theme.spacing.xs
                radius: Theme.radiusSmall
                color: clockMouse.containsMouse ? Theme.surface : "transparent"
                z: -1

                Behavior on color {
                    ColorAnimation { duration: Theme.animationFast; easing.type: Theme.easingType }
                }
            }

            MouseArea {
                id: clockMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    const wasOpen = calendar.shown;
                    Services.UiState.dismissAll();
                    calendar.shown = !wasOpen;
                }
            }
        }
    }

    CalendarPopup {
        id: calendar
        anchorItem: clockArea
    }

    Component {
        id: dateTextComponent

        Text {
            text: Qt.formatDateTime(clock.date, Config.Settings.dateFormat)
            color: Theme.mutedForeground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
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
