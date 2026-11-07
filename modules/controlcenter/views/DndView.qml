import QtQuick
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
        title: "Do not disturb"
        subtitle: Services.Notifications.doNotDisturb
            ? "Notifications are silenced" : "Notifications are allowed"
        trailing: Services.Notifications.doNotDisturb ? "On" : "Off"
        active: Services.Notifications.doNotDisturb
        onClicked: Services.Notifications.toggleDnd()
    }

    Text {
        width: parent.width
        text: "The notification daemon and history arrive in Milestone 4. This switch currently controls the shared Do Not Disturb state."
        color: Theme.mutedForeground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        wrapMode: Text.WordWrap
    }
}
