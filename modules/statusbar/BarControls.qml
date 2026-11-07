import QtQuick
import "../../config" as Config
import "../../themes"
import "../../components" as Components
import "../../services" as Services

Row {
    id: root

    property var controller: null
    spacing: Theme.spacing.md

    function iconFor(id) {
        if (id === "notifications") return "\uf0f3";
        if (id === "network") return "\uf1eb";
        if (id === "bluetooth") return "\uf293";
        if (id === "audio") return "\uf028";
        if (id === "power") return "\uf011";
        return "\uf111";
    }

    Repeater {
        model: Config.Settings.barVisibleItems()

        delegate: Item {
            id: buttonSlot

            required property var modelData
            required property int index

            readonly property string itemId: modelData.id

            width: Theme.buttonSize
            height: Theme.buttonSize
            anchors.verticalCenter: parent.verticalCenter
            z: dragHandler.active ? 100 : 0

            Component.onCompleted: {
                if (root.controller)
                    root.controller.registerButton(itemId, buttonSlot);
            }

            Component.onDestruction: {
                if (root.controller)
                    root.controller.unregisterButton(itemId, buttonSlot);
            }

            Loader {
                anchors.fill: parent
                sourceComponent: {
                    if (buttonSlot.itemId === "notifications")
                        return notificationsButton;
                    if (buttonSlot.itemId === "network")
                        return networkButton;
                    if (buttonSlot.itemId === "bluetooth")
                        return bluetoothButton;
                    if (buttonSlot.itemId === "audio")
                        return audioButton;
                    if (buttonSlot.itemId === "power")
                        return powerButton;
                    return null;
                }
            }

            Rectangle {
                id: ghost
                width: buttonSlot.width
                height: buttonSlot.height
                radius: Theme.radiusSmall
                color: Theme.surfaceElevated
                border.width: Theme.borderWidth
                border.color: Theme.primary
                opacity: 0.95
                visible: dragHandler.active
                z: 100

                Text {
                    anchors.centerIn: parent
                    text: root.iconFor(buttonSlot.itemId)
                    color: Theme.primary
                    font.family: Theme.iconFontFamily
                    font.pixelSize: Theme.iconSize
                }
            }

            DragHandler {
                id: dragHandler
                target: ghost
                xAxis.enabled: true
                yAxis.enabled: false

                onActiveChanged: {
                    if (active) {
                        ghost.x = 0;
                        return;
                    }

                    const items = Config.Settings.barVisibleItems();
                    const step = Theme.buttonSize + root.spacing;
                    let targetIndex = Math.round(
                        (buttonSlot.x + dragHandler.persistentTranslation.x) / step);
                    targetIndex = Math.max(0, Math.min(items.length - 1, targetIndex));
                    ghost.x = 0;

                    if (targetIndex >= 0 && targetIndex < items.length
                        && targetIndex !== buttonSlot.index
                        && items[targetIndex].id !== buttonSlot.itemId) {
                        const sourceId = buttonSlot.itemId;
                        const targetId = items[targetIndex].id;
                        const after = targetIndex > buttonSlot.index;
                        Qt.callLater(() => Config.Settings.moveBarItemRelative(sourceId, targetId, after));
                    }
                }
            }

            Component {
                id: notificationsButton
                NotificationButton {}
            }

            Component {
                id: networkButton
                Components.IconButton {
                    anchors.fill: parent
                    icon: Services.Network.wifiConnected ? "\uf1eb"
                        : Services.Network.wiredConnected ? "\uf0e8" : "\uf1eb"
                    iconColor: Services.Network.connected ? Theme.foreground : Theme.mutedForeground
                    active: root.controller ? root.controller.isOpen("network") : false
                    tooltip: Services.Network.wifiConnected ? "Wi-Fi connected"
                        : Services.Network.wiredConnected ? "Ethernet connected" : "Disconnected"
                    onClicked: if (root.controller) root.controller.toggleNetwork()
                }
            }

            Component {
                id: bluetoothButton
                Components.IconButton {
                    anchors.fill: parent
                    icon: "\uf293"
                    iconColor: Services.Bluetooth.enabled ? Theme.foreground : Theme.mutedForeground
                    active: root.controller ? root.controller.isOpen("bluetooth") : false
                    tooltip: !Services.Bluetooth.available ? "No Bluetooth adapter"
                        : Services.Bluetooth.enabled ? "Bluetooth on" : "Bluetooth off"
                    onClicked: if (root.controller) root.controller.toggleBluetooth()
                }
            }

            Component {
                id: audioButton
                Components.IconButton {
                    anchors.fill: parent
                    icon: Services.Audio.muted ? "\uf026"
                        : Services.Audio.volume > 0.5 ? "\uf028" : "\uf027"
                    iconColor: Services.Audio.muted ? Theme.mutedForeground : Theme.foreground
                    active: root.controller ? root.controller.isOpen("audio") : false
                    tooltip: Services.Audio.sink
                        ? (Services.Audio.muted ? "Muted" : Services.Audio.volumePercent + "%")
                        : "No audio device"
                    onClicked: if (root.controller) root.controller.toggleAudio()
                }
            }

            Component {
                id: powerButton
                Components.IconButton {
                    anchors.fill: parent
                    icon: "\uf011"
                    active: root.controller ? root.controller.isOpen("power") : false
                    tooltip: "Power menu"
                    onClicked: if (root.controller) root.controller.togglePowerMenu(false)
                }
            }
        }
    }
}
