import QtQuick
import "../../components" as Components
import "../../themes"

Components.Popup {
    id: root

    popupWidth: 300
    padding: Theme.padding
    spacing: Theme.spacing.md

    property date today: new Date()
    property int viewYear: new Date().getFullYear()
    property int viewMonth: new Date().getMonth()
    property date selectedDate: new Date()

    readonly property var monthNames: [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]
    readonly property var weekdayNames: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

    readonly property int daysInMonth: new Date(viewYear, viewMonth + 1, 0).getDate()
    readonly property int firstWeekday: (new Date(viewYear, viewMonth, 1).getDay() + 6) % 7
    readonly property int cellCount: Math.ceil((firstWeekday + daysInMonth) / 7) * 7

    onShownChanged: {
        if (shown) {
            today = new Date();
            viewYear = today.getFullYear();
            viewMonth = today.getMonth();
        }
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: root.today = new Date()
    }

    Row {
        width: parent.width
        height: Theme.rowHeight - Theme.spacing.xs

        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.rowHeight - Theme.spacing.xs
            text: "\u2039"
            color: previousMouse.containsMouse ? Theme.primary : Theme.mutedForeground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeXLarge
            horizontalAlignment: Text.AlignHCenter

            MouseArea {
                id: previousMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (root.viewMonth === 0) {
                        root.viewMonth = 11;
                        root.viewYear--;
                    } else {
                        root.viewMonth--;
                    }
                }
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 56
            text: root.monthNames[root.viewMonth] + " " + root.viewYear
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Theme.fontWeightBold
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.rowHeight - Theme.spacing.xs
            text: "\u203a"
            color: nextMouse.containsMouse ? Theme.primary : Theme.mutedForeground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeXLarge
            horizontalAlignment: Text.AlignHCenter

            MouseArea {
                id: nextMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (root.viewMonth === 11) {
                        root.viewMonth = 0;
                        root.viewYear++;
                    } else {
                        root.viewMonth++;
                    }
                }
            }
        }
    }

    Row {
        width: parent.width

        Repeater {
            model: root.weekdayNames

            delegate: Text {
                required property var modelData
                width: parent.width / 7
                text: modelData
                color: Theme.mutedForeground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    Grid {
        width: parent.width
        columns: 7

        Repeater {
            model: root.cellCount

            delegate: Item {
                id: cell
                required property int index

                readonly property int day: index - root.firstWeekday + 1
                readonly property bool valid: day >= 1 && day <= root.daysInMonth
                readonly property bool isToday: valid
                    && day === root.today.getDate()
                    && root.viewMonth === root.today.getMonth()
                    && root.viewYear === root.today.getFullYear()
                readonly property bool isSelected: valid
                    && day === root.selectedDate.getDate()
                    && root.viewMonth === root.selectedDate.getMonth()
                    && root.viewYear === root.selectedDate.getFullYear()

                width: (root.popupWidth - root.padding * 2) / 7
                height: Theme.rowHeight

                Rectangle {
                    anchors.centerIn: parent
                    width: Theme.rowHeight - Theme.spacing.xs
                    height: Theme.rowHeight - Theme.spacing.sm
                    radius: Theme.radiusSmall
                    color: cell.isSelected ? Theme.primary
                        : cell.isToday ? Theme.surfaceElevated
                        : cellMouse.containsMouse && cell.valid ? Theme.surface
                        : "transparent"
                    border.width: cell.isToday && !cell.isSelected ? 1 : 0
                    border.color: Theme.primary

                    Text {
                        anchors.centerIn: parent
                        text: cell.valid ? cell.day : ""
                        color: cell.isSelected ? Theme.onPrimary
                            : cell.valid ? Theme.foreground : Theme.mutedForeground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeBase
                        font.weight: cell.isToday || cell.isSelected ? Theme.fontWeightBold : Theme.fontWeightNormal
                    }
                }

                MouseArea {
                    id: cellMouse
                    anchors.fill: parent
                    enabled: cell.valid
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.selectedDate = new Date(root.viewYear, root.viewMonth, cell.day)
                }
            }
        }
    }

    Item {
        width: parent.width
        height: Theme.rowHeight

        Rectangle {
            anchors.centerIn: parent
            width: Theme.spacing.xl * 5
            height: Theme.rowHeight - Theme.spacing.sm
            radius: Theme.radiusSmall
            color: todayMouse.containsMouse ? Theme.surfaceElevated : Theme.surface

            Text {
                anchors.centerIn: parent
                text: "Today"
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeBase
            }

            MouseArea {
                id: todayMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.today = new Date();
                    root.viewYear = root.today.getFullYear();
                    root.viewMonth = root.today.getMonth();
                    root.selectedDate = root.today;
                }
            }
        }
    }
}
