import QtQuick
import QtQuick.Layouts
import "../themes"
import "../services" as Services

Column {
    id: root

    signal passwordRequired(var network)

    width: parent ? parent.width : 300
    spacing: Theme.spacing.md

    RowLayout {
        width: parent.width
        spacing: Theme.spacing.md

        Text {
            text: "\uf1eb"
            color: Services.Network.connected ? Theme.primary : Theme.mutedForeground
            font.family: Theme.iconFontFamily
            font.pixelSize: Theme.fontSize
        }

        Text {
            Layout.fillWidth: true
            text: "Wi-Fi"
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeBase
        }

        Text {
            text: Services.Network.wifiEnabled ? (Services.Network.scanning ? "Scanning…" : "On") : "Off"
            color: Theme.mutedForeground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
        }

        ToggleSwitch {
            checked: Services.Network.wifiEnabled
            onToggled: Services.Network.toggleWifi()
        }
    }

    Text {
        width: parent.width
        visible: !Services.Network.wifiEnabled
        text: "Wi-Fi is disabled"
        color: Theme.mutedForeground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
    }

    Column {
        width: parent.width
        spacing: Theme.spacing.xs
        visible: Services.Network.wifiEnabled

        Repeater {
            model: Services.Network.networkList.slice(0, 12)

            delegate: Rectangle {
                id: networkRow
                required property var modelData

                readonly property bool open: Services.Network.isOpenNetwork(modelData)
                readonly property bool connected: modelData.connected
                readonly property bool busy: modelData.stateChanging

                width: root.width
                height: Theme.rowHeight
                radius: Theme.radiusSmall
                color: connected ? Theme.surface
                    : networkMouse.containsMouse ? Theme.surface
                    : "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.spacing.md
                    anchors.rightMargin: Theme.spacing.md
                    spacing: Theme.spacing.md

                    Text {
                        text: "\uf1eb"
                        color: networkRow.connected ? Theme.primary : Theme.mutedForeground
                        font.family: Theme.iconFontFamily
                        font.pixelSize: Theme.fontSizeBase
                    }

                    Text {
                        Layout.fillWidth: true
                        text: networkRow.modelData.name || "Hidden network"
                        elide: Text.ElideRight
                        color: networkRow.connected ? Theme.primary : Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeBase
                    }

                    Text {
                        visible: !networkRow.open
                        text: "\uf023"
                        color: Theme.mutedForeground
                        font.family: Theme.iconFontFamily
                        font.pixelSize: Theme.fontSizeTiny
                    }

                    Text {
                        text: Math.round(networkRow.modelData.signalStrength * 100) + "%"
                        color: Theme.mutedForeground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeTiny
                    }

                    Text {
                        width: 58
                        horizontalAlignment: Text.AlignRight
                        text: networkRow.connected ? "Disconnect"
                            : networkRow.busy ? "Connecting…"
                            : networkRow.modelData.known ? "Saved" : "Connect"
                        color: networkRow.connected ? Theme.primary
                            : networkRow.busy ? Theme.secondary
                            : Theme.mutedForeground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeTiny
                    }
                }

                MouseArea {
                    id: networkMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: !networkRow.busy
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (networkRow.connected) {
                            Services.Network.disconnectNetwork(networkRow.modelData);
                        } else if (networkRow.modelData.known || networkRow.open) {
                            Services.Network.connectNetwork(networkRow.modelData);
                        } else if (Services.Network.requiresPsk(networkRow.modelData)) {
                            root.passwordRequired(networkRow.modelData);
                        } else {
                            Services.Network.errorText = "Unsupported security: "
                                + Services.Network.securityLabel(networkRow.modelData);
                        }
                    }
                }
            }
        }

        Text {
            width: parent.width
            visible: Services.Network.networkList.length === 0
                && Services.Network.wifiEnabled
            text: Services.Network.scanning ? "Scanning for networks…" : "No Wi-Fi networks found"
            color: Theme.mutedForeground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
        }
    }

    Text {
        width: parent.width
        visible: Services.Network.errorText.length > 0
        text: Services.Network.errorText
        color: Theme.error
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        wrapMode: Text.WordWrap
    }

    Rectangle {
        width: parent.width
        height: Theme.borderWidth
        color: Theme.border
    }

    Text {
        width: parent.width
        text: "Ethernet"
        color: Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeBase
        font.weight: Theme.fontWeightBold
    }

    Column {
        width: parent.width
        spacing: Theme.spacing.xs
        visible: Services.Network.wiredDevices.length > 0

        Repeater {
            model: Services.Network.wiredDevices

            delegate: Rectangle {
                id: wiredRow
                required property var modelData

                width: root.width
                height: Theme.rowHeight
                radius: Theme.radiusSmall
                color: "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.spacing.md
                    anchors.rightMargin: Theme.spacing.md
                    spacing: Theme.spacing.md

                    Text {
                        text: "\uf0e8"
                        color: wiredRow.modelData.connected ? Theme.primary : Theme.mutedForeground
                        font.family: Theme.iconFontFamily
                        font.pixelSize: Theme.fontSizeBase
                    }

                    Text {
                        Layout.fillWidth: true
                        text: wiredRow.modelData.name
                        elide: Text.ElideRight
                        color: Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeBase
                    }

                    Text {
                        text: wiredRow.modelData.connected ? "Connected" : "Disconnected"
                        color: wiredRow.modelData.connected ? Theme.primary : Theme.mutedForeground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeTiny
                    }
                }
            }
        }
    }

    Text {
        width: parent.width
        visible: Services.Network.wiredDevices.length === 0
        text: "No Ethernet interface detected"
        color: Theme.mutedForeground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
    }
}
