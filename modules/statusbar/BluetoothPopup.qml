import QtQuick
import QtQuick.Layouts
import "../../themes"
import "../../services" as Services
import "../../components" as Components

Components.Popup {
    id: root

    popupWidth: 330
    padding: Theme.padding
    spacing: Theme.spacing.md

    Connections {
        target: root
        function onShownChanged() {
            Services.Bluetooth.setDiscovering(root.shown);
            if (root.shown)
                Services.Bluetooth.clearError();
        }
    }

    Text {
        width: parent.width
        text: "Bluetooth"
        color: Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.weight: Theme.fontWeightBold
    }

    RowLayout {
        width: parent.width
        spacing: Theme.spacing.md

        Text {
            text: "\uf293"
            color: Services.Bluetooth.enabled ? Theme.primary : Theme.mutedForeground
            font.family: Theme.iconFontFamily
            font.pixelSize: Theme.fontSize
        }

        Text {
            Layout.fillWidth: true
            text: !Services.Bluetooth.available ? "Unavailable"
                : Services.Bluetooth.enabled ? (Services.Bluetooth.adapter.discovering ? "Searching…" : "On")
                : "Off"
            color: Services.Bluetooth.enabled ? Theme.foreground : Theme.mutedForeground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeBase
        }

        Components.ToggleSwitch {
            checked: Services.Bluetooth.enabled
            enabled: Services.Bluetooth.available
            opacity: Services.Bluetooth.available ? 1 : 0.4
            onToggled: Services.Bluetooth.toggle()
        }
    }

    Text {
        width: parent.width
        visible: !Services.Bluetooth.available
        text: "No Bluetooth adapter detected"
        color: Theme.mutedForeground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
    }

    Column {
        width: parent.width
        spacing: Theme.spacing.xs
        visible: Services.Bluetooth.available && Services.Bluetooth.enabled

        Repeater {
            model: Services.Bluetooth.deviceList.slice(0, 8)

            delegate: Rectangle {
                id: deviceRow
                required property var modelData

                readonly property bool connected: modelData.connected
                readonly property bool pairing: modelData.pairing
                readonly property bool connecting: Services.Bluetooth.isConnecting(modelData)
                readonly property bool paired: modelData.paired || modelData.bonded

                width: root.popupWidth - root.padding * 2
                height: Theme.rowHeight
                radius: Theme.radiusSmall
                color: connected ? Theme.surface
                    : deviceMouse.containsMouse ? Theme.surface
                    : "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.spacing.md
                    anchors.rightMargin: Theme.spacing.md
                    spacing: Theme.spacing.md

                    Text {
                        text: "\uf293"
                        color: deviceRow.connected ? Theme.primary : Theme.mutedForeground
                        font.family: Theme.iconFontFamily
                        font.pixelSize: Theme.fontSizeBase
                    }

                    Text {
                        Layout.fillWidth: true
                        text: Services.Bluetooth.deviceLabel(deviceRow.modelData)
                        elide: Text.ElideRight
                        color: deviceRow.connected ? Theme.primary : Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeBase
                    }

                    Text {
                        visible: deviceRow.modelData.batteryAvailable
                        text: Math.round(deviceRow.modelData.battery * 100) + "%"
                        color: Theme.mutedForeground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeTiny
                    }

                    Text {
                        width: 58
                        horizontalAlignment: Text.AlignRight
                        text: deviceRow.connected ? "Disconnect"
                            : deviceRow.pairing ? "Pairing…"
                            : deviceRow.connecting ? "Connecting…"
                            : deviceRow.paired ? "Connect" : "Pair"
                        color: deviceRow.connected ? Theme.primary
                            : (deviceRow.pairing || deviceRow.connecting) ? Theme.secondary
                            : Theme.mutedForeground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeTiny
                    }
                }

                MouseArea {
                    id: deviceMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: !deviceRow.pairing
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Services.Bluetooth.toggleDevice(deviceRow.modelData)
                }
            }
        }

        Text {
            width: parent.width
            visible: Services.Bluetooth.deviceList.length === 0
            text: Services.Bluetooth.available && Services.Bluetooth.adapter.discovering
                ? "Searching for devices…"
                : "No Bluetooth devices found"
            color: Theme.mutedForeground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
        }
    }

    Text {
        width: parent.width
        visible: Services.Bluetooth.errorText.length > 0
        text: Services.Bluetooth.errorText
        color: Theme.error
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        wrapMode: Text.WordWrap
    }
}
