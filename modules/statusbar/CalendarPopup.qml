import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../components" as Components
import "../../themes"
import "../../config" as Config
import "../../services" as Services

Components.Popup {
    id: root

    popupWidth: Config.Settings.calendarWidth
    padding: Theme.padding
    spacing: Theme.spacing.md

    property date selectedDate: new Date()
    property int viewYear: new Date().getFullYear()
    property int viewMonth: new Date().getMonth()

    readonly property date today: clock.date
    readonly property int contentWidth: popupWidth - padding * 2
    readonly property int cellGap: 2
    readonly property int cellWidth: Math.floor((contentWidth - cellGap * 6) / 7)
    readonly property int cellHeight: Config.Settings.calendarCellHeight

    readonly property int firstWeekday: (new Date(viewYear, viewMonth, 1).getDay()
        - Config.Settings.calendarFirstDay + 7) % 7
    readonly property int daysInMonth: new Date(viewYear, viewMonth + 1, 0).getDate()
    readonly property string monthTitle: Qt.formatDateTime(new Date(viewYear, viewMonth, 1), "MMMM yyyy")
    readonly property int weekNumber: {
        if (selectedDate.getFullYear() === viewYear && selectedDate.getMonth() === viewMonth)
            return isoWeek(selectedDate);
        return isoWeek(new Date(viewYear, viewMonth, 1));
    }
    readonly property string timeText: Qt.formatDateTime(clock.date, "HH:mm")
    readonly property string secondsText: Qt.formatDateTime(clock.date, "ss")
    readonly property string longDateText: Qt.formatDateTime(clock.date, "dddd, MMMM d, yyyy")

    readonly property var weekdayNames: {
        const result = [];
        const start = new Date(2024, 0, 7 + Config.Settings.calendarFirstDay);
        for (let i = 0; i < 7; i++)
            result.push(Qt.formatDateTime(new Date(start.getTime() + i * 86400000), "ddd"));
        return result;
    }

    SystemClock {
        id: clock
        enabled: true
        precision: SystemClock.Seconds
    }

    Connections {
        target: root
        function onShownChanged() {
            if (!root.shown)
                return;
            root.viewYear = clock.date.getFullYear();
            root.viewMonth = clock.date.getMonth();
            root.selectedDate = new Date(
                clock.date.getFullYear(), clock.date.getMonth(), clock.date.getDate());
            Services.Weather.refresh();
        }
    }

    function isoWeek(date) {
        const d = new Date(date.getFullYear(), date.getMonth(), date.getDate());
        const day = (d.getDay() + 6) % 7;
        d.setDate(d.getDate() - day + 3);
        const firstThursday = new Date(d.getFullYear(), 0, 4);
        const firstDay = (firstThursday.getDay() + 6) % 7;
        firstThursday.setDate(firstThursday.getDate() - firstDay + 3);
        return 1 + Math.round((d.getTime() - firstThursday.getTime()) / 604800000);
    }

    function sameDay(a, b) {
        return a.getFullYear() === b.getFullYear()
            && a.getMonth() === b.getMonth()
            && a.getDate() === b.getDate();
    }

    function cellDate(index) {
        return new Date(viewYear, viewMonth, 1 + index - firstWeekday);
    }

    function previousMonth() {
        if (viewMonth === 0) {
            viewMonth = 11;
            viewYear--;
        } else {
            viewMonth--;
        }
    }

    function nextMonth() {
        if (viewMonth === 11) {
            viewMonth = 0;
            viewYear++;
        } else {
            viewMonth++;
        }
    }

    function goToday() {
        viewYear = clock.date.getFullYear();
        viewMonth = clock.date.getMonth();
        selectedDate = new Date(viewYear, viewMonth, clock.date.getDate());
    }

    function weatherColor() {
        const text = (Services.Weather.condition || "").toLowerCase();
        if (text.indexOf("rain") >= 0 || text.indexOf("drizzle") >= 0
            || text.indexOf("shower") >= 0 || text.indexOf("snow") >= 0
            || text.indexOf("sleet") >= 0)
            return Theme.info;
        if (text.indexOf("cloud") >= 0 || text.indexOf("overcast") >= 0
            || text.indexOf("mist") >= 0 || text.indexOf("fog") >= 0)
            return Theme.mutedForeground;
        return Theme.warning;
    }

    RowLayout {
        width: parent.width
        spacing: Theme.spacing.md

        Rectangle {
            Layout.preferredWidth: 48
            Layout.preferredHeight: 48
            Layout.alignment: Qt.AlignVCenter
            radius: Theme.radius
            color: Theme.accentSurface
            border.width: Theme.borderWidth
            border.color: Theme.accentBorder

            Text {
                anchors.centerIn: parent
                text: "\uf017"
                color: Theme.primary
                font.family: Theme.iconFontFamily
                font.pixelSize: Theme.fontSizeXLarge
            }
        }

        Column {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            Row {
                spacing: Theme.spacing.xs

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.timeText
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeXLarge
                    font.weight: Theme.fontWeightBold
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: ":" + root.secondsText
                    color: Theme.primary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeLarge
                    font.weight: Theme.fontWeightBold
                }

            }

            Text {
                width: parent.width
                text: root.longDateText
                color: Theme.mutedForeground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                elide: Text.ElideRight
            }
        }

        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 170
            Layout.preferredHeight: 48
            visible: Config.Settings.calendarShowWeather
                && (Services.Weather.available || Services.Weather.lastError.length > 0)
            radius: Theme.radiusSmall
            color: Theme.surface
            border.width: Theme.borderWidth
            border.color: Theme.subtleBorder

            RowLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacing.sm
                spacing: Theme.spacing.sm

                Text {
                    Layout.alignment: Qt.AlignVCenter
                    text: Services.Weather.available ? Services.Weather.icon : "\uf0c2"
                    color: Services.Weather.available ? root.weatherColor() : Theme.mutedForeground
                    font.family: Theme.iconFontFamily
                    font.pixelSize: Theme.fontSizeLarge
                }

                Column {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 1

                    Text {
                        width: parent.width
                        text: Services.Weather.available ? Services.Weather.location : "Weather"
                        color: Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeTiny
                        font.weight: Theme.fontWeightBold
                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width
                        text: Services.Weather.available
                            ? (Services.Weather.temperature + "°C · "
                                + Services.Weather.condition + " · "
                                + Services.Weather.humidity + "%")
                            : "Unavailable"
                        color: Theme.mutedForeground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeTiny
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }

    Rectangle {
        width: parent.width
        height: Theme.borderWidth
        color: Theme.subtleBorder
    }

    RowLayout {
        width: parent.width
        spacing: Theme.spacing.sm

        Text {
            Layout.alignment: Qt.AlignVCenter
            text: root.monthTitle
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeMedium
            font.weight: Theme.fontWeightBold
        }

        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            visible: Config.Settings.calendarShowWeekNumbers
            width: weekLabel.implicitWidth + Theme.spacing.lg
            height: Theme.spacing.xl + Theme.spacing.xs
            radius: height / 2
            color: Theme.accentSurface
            border.width: Theme.borderWidth
            border.color: Theme.accentBorder

            Text {
                id: weekLabel
                anchors.centerIn: parent
                text: "Week " + root.weekNumber
                color: Theme.primary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeTiny
                font.weight: Theme.fontWeightBold
            }
        }

        Item { Layout.fillWidth: true }

        BarRoundButton {
            icon: "\uf053"
            tooltip: "Previous month"
            onClicked: root.previousMonth()
        }

        Rectangle {
            Layout.preferredWidth: 54
            Layout.preferredHeight: 28
            Layout.alignment: Qt.AlignVCenter
            radius: Theme.radiusSmall
            color: todayMouse.containsMouse ? Theme.surfaceElevated : Theme.accentSurface
            border.width: Theme.borderWidth
            border.color: Theme.accentBorder

            Text {
                anchors.centerIn: parent
                text: "Today"
                color: Theme.primary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Theme.fontWeightBold
            }

            MouseArea {
                id: todayMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.goToday()
            }
        }

        BarRoundButton {
            icon: "\uf054"
            tooltip: "Next month"
            onClicked: root.nextMonth()
        }
    }

    Grid {
        columns: 7
        columnSpacing: root.cellGap
        rowSpacing: 0

        Repeater {
            model: root.weekdayNames

            delegate: Text {
                required property var modelData
                required property int index

                readonly property int dayOfWeek: (index + Config.Settings.calendarFirstDay) % 7

                width: root.cellWidth
                height: 18
                text: modelData
                color: dayOfWeek === 5 ? Theme.warning
                    : dayOfWeek === 6 ? Theme.error
                    : Theme.mutedForeground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Theme.fontWeightBold
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    Grid {
        columns: 7
        columnSpacing: root.cellGap
        rowSpacing: root.cellGap

        Repeater {
            model: 42

            delegate: Item {
                id: cell
                required property int index

                readonly property date dateValue: root.cellDate(index)
                readonly property bool inMonth: dateValue.getMonth() === root.viewMonth
                    && dateValue.getFullYear() === root.viewYear
                readonly property bool isToday: Config.Settings.calendarHighlightToday
                    && root.sameDay(dateValue, root.today)
                readonly property bool isSelected: root.sameDay(dateValue, root.selectedDate)

                width: root.cellWidth
                height: root.cellHeight

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 1
                    radius: Theme.radiusSmall
                    color: cell.isSelected ? Theme.primary
                        : cell.isToday ? Theme.accentSurface
                        : cellMouse.containsMouse
                            && (cell.inMonth || Config.Settings.calendarShowAdjacentMonths)
                            ? Theme.surface : "transparent"
                    border.width: cell.isToday && !cell.isSelected ? Theme.borderWidth : 0
                    border.color: Theme.accentBorder

                    Text {
                        anchors.centerIn: parent
                        visible: cell.inMonth || Config.Settings.calendarShowAdjacentMonths
                        text: cell.dateValue.getDate()
                        color: cell.isSelected ? Theme.onPrimary
                            : cell.isToday ? Theme.primary
                            : cell.inMonth ? Theme.foreground : Theme.disabled
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeBase
                        font.weight: cell.isToday || cell.isSelected
                            ? Theme.fontWeightBold : Theme.fontWeightNormal
                    }

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 4
                        visible: cell.isToday
                        width: Theme.spacing.xs + 1
                        height: width
                        radius: width / 2
                        color: cell.isSelected ? Theme.onPrimary : Theme.primary
                    }
                }

                MouseArea {
                    id: cellMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: cell.inMonth || Config.Settings.calendarShowAdjacentMonths
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (!cell.inMonth) {
                            root.viewYear = cell.dateValue.getFullYear();
                            root.viewMonth = cell.dateValue.getMonth();
                        }
                        root.selectedDate = cell.dateValue;
                    }
                }
            }
        }
    }

}
