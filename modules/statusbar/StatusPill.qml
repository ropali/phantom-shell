import QtQuick
import "../../config" as Config
import "../../themes"
import "../../components" as Components
import "../../services" as Services

BarPill {
    id: root

    property var controller: null

    readonly property bool hasControls: {
        const items = Config.Settings.barVisibleItems();
        for (let i = 0; i < items.length; i++) {
            if (items[i].id !== "power")
                return true;
        }
        return false;
    }

    readonly property color batteryColor: !Services.Battery.available ? Theme.mutedForeground
        : Services.Battery.percentage <= 15 ? Theme.error
        : Services.Battery.percentage <= 30 ? Theme.warning
        : Theme.success

    horizontalPadding: Theme.spacing.sm
    contentSpacing: Theme.spacing.sm
    visible: hasControls || Services.Media.available || Services.Battery.available

    function batteryIcon() {
        if (Services.Battery.charging)
            return "\uf0e7";
        if (!Services.Battery.available)
            return "\uf0e7";
        if (Services.Battery.percentage >= 90)
            return "\uf240";
        if (Services.Battery.percentage >= 65)
            return "\uf241";
        if (Services.Battery.percentage >= 40)
            return "\uf242";
        if (Services.Battery.percentage >= 15)
            return "\uf243";
        return "\uf244";
    }

    BarControls {
        excludedIds: ["power"]
        controller: root.controller
    }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        visible: Services.Media.available || Services.Battery.available
        width: 1
        height: Theme.controlHeight - Theme.spacing.lg
        color: Theme.subtleBorder
    }

    Components.IconButton {
        visible: Services.Media.available
        buttonSize: Theme.controlHeight - Theme.spacing.md
        iconSize: Theme.fontSize
        icon: Services.Media.player
            && Services.Media.player.identity
            && Services.Media.player.identity.toLowerCase().indexOf("spotify") >= 0
            ? "\uf1bc" : "\uf001"
        iconColor: Theme.success
        tooltip: Services.Media.title.length > 0 ? Services.Media.title : "Media"
        onClicked: if (root.controller) root.controller.toggleControlCenter()
    }

    Row {
        anchors.verticalCenter: parent.verticalCenter
        visible: Services.Battery.available
        spacing: Theme.spacing.xs

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.batteryIcon()
            color: root.batteryColor
            font.family: Theme.iconFontFamily
            font.pixelSize: Theme.fontSizeSmall
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Services.Battery.percentage + "%"
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Theme.fontWeightBold
        }
    }
}
