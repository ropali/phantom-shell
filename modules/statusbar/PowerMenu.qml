import QtQuick
import Quickshell
import "../../components" as Components
import "../../themes"

Components.Popup {
    id: root

    popupWidth: 220
    padding: Theme.padding
    spacing: Theme.spacing.xs

    readonly property var actions: [
        { label: "Lock screen", icon: "\uf023", action: "lock" },
        { label: "Logout", icon: "\uf2f5", action: "logout" },
        { label: "Suspend", icon: "\uf186", action: "suspend" },
        { label: "Reboot", icon: "\uf021", action: "reboot" },
        { label: "Shutdown", icon: "\uf011", action: "shutdown" }
    ]

    function run(action) {
        if (action === "lock")
            Quickshell.execDetached(["loginctl", "lock-session"]);
        else if (action === "logout")
            Quickshell.execDetached(["hyprctl", "dispatch", "exit"]);
        else if (action === "suspend")
            Quickshell.execDetached(["systemctl", "suspend"]);
        else if (action === "reboot")
            Quickshell.execDetached(["systemctl", "reboot"]);
        else if (action === "shutdown")
            Quickshell.execDetached(["systemctl", "poweroff"]);
    }

    Repeater {
        model: root.actions

        delegate: Rectangle {
            id: actionRow
            required property var modelData

            width: root.popupWidth - root.padding * 2
            height: Theme.controlHeight
            radius: Theme.radiusSmall
            color: actionMouse.containsMouse
                ? (modelData.action === "shutdown" || modelData.action === "reboot" ? Theme.surfaceElevated : Theme.surface)
                : "transparent"

            Row {
                anchors.left: parent.left
                anchors.leftMargin: Theme.spacing.md
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.spacing.md

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: actionRow.modelData.icon
                    color: actionRow.modelData.action === "shutdown" || actionRow.modelData.action === "reboot"
                        ? Theme.error : Theme.mutedForeground
                    font.family: Theme.iconFontFamily
                    font.pixelSize: Theme.fontSize
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: actionRow.modelData.label
                    color: actionRow.modelData.action === "shutdown" || actionRow.modelData.action === "reboot"
                        ? Theme.error : Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMedium
                }
            }

            MouseArea {
                id: actionMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.shown = false;
                    root.run(actionRow.modelData.action);
                }
            }
        }
    }
}
