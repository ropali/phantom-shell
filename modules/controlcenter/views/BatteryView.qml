import QtQuick
import QtQuick.Layouts
import "../../../themes"
import "../../../services" as Services

Column {
    id: root

    readonly property int preferredHeight: implicitHeight

    anchors.fill: parent
    spacing: Theme.spacing.md

    Text {
        width: parent.width
        text: Services.Battery.available
            ? Services.Battery.percentage + "%" : "AC power"
        color: Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeXLarge
        font.weight: Theme.fontWeightBold
    }

    Text {
        width: parent.width
        text: Services.Battery.available
            ? Services.Battery.stateLabel
                + (Services.Battery.timeLabel.length > 0 ? " · " + Services.Battery.timeLabel + " remaining" : "")
            : "No battery detected; the system is running on AC power."
        color: Theme.mutedForeground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeBase
        wrapMode: Text.WordWrap
    }

    Rectangle {
        width: parent.width
        height: Theme.borderWidth
        color: Theme.border
    }

    Text {
        width: parent.width
        text: Services.Battery.onBattery ? "On battery" : "On AC power"
        color: Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeBase
    }
}
