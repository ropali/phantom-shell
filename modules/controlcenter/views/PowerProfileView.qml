import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import "../../../themes"
import "../../../services" as Services
import "../../../components" as Components

Column {
    id: root

    readonly property int preferredHeight: implicitHeight

    anchors.fill: parent
    spacing: Theme.spacing.md

    Repeater {
        model: Services.PowerProfiles.options

        delegate: Components.SettingRow {
            required property var modelData

            width: root.width
            title: modelData.label
            subtitle: modelData.id === PowerProfile.PowerSaver ? "Lower power use"
                : modelData.id === PowerProfile.Balanced ? "Everyday use"
                : "Maximum performance"
            trailing: Services.PowerProfiles.profile === modelData.id ? "Active" : ""
            active: Services.PowerProfiles.profile === modelData.id
            isEnabled: modelData.id !== PowerProfile.Performance
                || Services.PowerProfiles.hasPerformanceProfile
            onClicked: Services.PowerProfiles.setProfile(modelData.id)
        }
    }

    Text {
        width: parent.width
        text: "Power profiles are provided by power-profiles-daemon through UPower."
        color: Theme.mutedForeground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        wrapMode: Text.WordWrap
    }
}
