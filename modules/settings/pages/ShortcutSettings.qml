import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../themes"
import "../../../components" as Components

Components.SettingsPage {
    id: page

    title: "Keyboard Shortcuts"
    icon: "\uf11c"
    description: "Phantom shortcuts and the Hyprland bindings that launch shell features."

    readonly property var shortcuts: [
        { keys: "SUPER + SPACE", action: "Open application launcher", source: "Hyprland", state: "Active" },
        { keys: "SUPER + ,", action: "Open Phantom settings", source: "Hyprland", state: "Active" },
        { keys: "SUPER + A", action: "Open control center", source: "Hyprland", state: "Planned" },
        { keys: "SUPER + N", action: "Open notification center", source: "Hyprland", state: "Planned" },
        { keys: "SUPER + T", action: "Cycle theme", source: "Phantom", state: "Planned" },
        { keys: "Escape", action: "Close settings", source: "Phantom", state: "Active" }
    ]

    Components.SettingsCard {
        title: "Registered shortcuts"
        description: "Hyprland-managed bindings are read from your existing keybindings file. Phantom does not rewrite them automatically."

        Repeater {
            model: page.shortcuts

            delegate: RowLayout {
                required property var modelData

                width: parent.width
                height: Theme.rowHeight
                spacing: Theme.spacing.md

                Rectangle {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: keyLabel.implicitWidth + Theme.spacing.md * 2
                    Layout.preferredHeight: 24
                    radius: Theme.radiusSmall
                    color: Theme.surface
                    border.width: Theme.borderWidth
                    border.color: Theme.subtleBorder

                    Text {
                        id: keyLabel
                        anchors.centerIn: parent
                        text: modelData.keys
                        color: Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeTiny
                        font.weight: Theme.fontWeightBold
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: modelData.action
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeBase
                    elide: Text.ElideRight
                }

                Text {
                    Layout.alignment: Qt.AlignVCenter
                    text: modelData.state
                    color: modelData.state === "Active" ? Theme.success : Theme.mutedForeground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeTiny
                    font.weight: Theme.fontWeightBold
                }
            }
        }
    }

    Components.SettingsCard {
        title: "Hyprland"
        description: "Global shortcuts are managed by Hyprland so they work even when Phantom is not focused."

        Components.SettingsInfoRow {
            label: "Keybindings file"
            value: Quickshell.env("HOME") + "/.config/hypr/keybindings.lua"
        }

        Components.SettingsButton {
            text: "Open keybindings"
            icon: "\uf08e"
            onClicked: Quickshell.execDetached([
                "xdg-open", Quickshell.env("HOME") + "/.config/hypr/keybindings.lua"
            ])
        }
    }
}
