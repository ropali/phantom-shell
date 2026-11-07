import QtQuick
import QtQuick.Layouts
import "../../../themes"
import "../../../services" as Services
import "../../../components" as Components

Column {
    id: root

    readonly property int preferredHeight: implicitHeight

    anchors.fill: parent
    spacing: Theme.spacing.md

    Components.SettingRow {
        width: parent.width
        title: "Night light"
        subtitle: Services.NightLight.enabled ? "Warm overlay active" : "Warm overlay disabled"
        trailing: Services.NightLight.enabled ? "On" : "Off"
        active: Services.NightLight.enabled
        onClicked: Services.NightLight.toggle()
    }

    Components.SettingSlider {
        label: "Temperature"
        value: Services.NightLight.temperature
        from: 2700
        to: 6500
        valueText: Services.NightLight.enabled ? Services.NightLight.temperature + "K" : "Off"
        isEnabled: Services.NightLight.available
        onMoved: (value) => Services.NightLight.setTemperature(value)
    }

    Text {
        width: parent.width
        text: "Lower temperatures remove more blue light. The overlay is click-through and applies to all displays."
        color: Theme.mutedForeground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        wrapMode: Text.WordWrap
    }
}
