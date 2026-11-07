import QtQuick
import "../../services" as Services
import "../../components" as Components
import "../../themes"
import "../theme"

Row {
    id: root
    spacing: Theme.spacing.md

    property var screenInfo: null

    function togglePopup(popup) {
        const wasOpen = popup.shown;
        Services.UiState.dismissAll();
        popup.shown = !wasOpen;
    }

    SystemTray {
        anchors.verticalCenter: parent.verticalCenter
    }

    NotificationButton {
        anchors.verticalCenter: parent.verticalCenter
    }

    Components.IconButton {
        id: themeButton
        anchors.verticalCenter: parent.verticalCenter
        icon: "\uf1fc"
        active: themeSwitcher.shown
        tooltip: ThemeManager.palette.name
        onClicked: root.togglePopup(themeSwitcher)
    }

    Components.IconButton {
        id: networkButton
        anchors.verticalCenter: parent.verticalCenter
        icon: Services.Network.wifiConnected ? "\uf1eb" : Services.Network.wiredConnected ? "\uf0e8" : "\uf1eb"
        iconColor: Services.Network.connected ? Theme.foreground : Theme.mutedForeground
        active: networkPopup.shown
        tooltip: Services.Network.wifiConnected ? "Wi-Fi connected"
            : Services.Network.wiredConnected ? "Ethernet connected" : "Disconnected"
        onClicked: root.togglePopup(networkPopup)
    }

    Components.IconButton {
        id: bluetoothButton
        anchors.verticalCenter: parent.verticalCenter
        icon: "\uf293"
        iconColor: Services.Bluetooth.enabled ? Theme.foreground : Theme.mutedForeground
        active: bluetoothPopup.shown
        tooltip: !Services.Bluetooth.available ? "No Bluetooth adapter"
            : Services.Bluetooth.enabled ? "Bluetooth on" : "Bluetooth off"
        onClicked: root.togglePopup(bluetoothPopup)
    }

    Components.IconButton {
        id: audioButton
        anchors.verticalCenter: parent.verticalCenter
        icon: Services.Audio.muted ? "\uf026" : Services.Audio.volume > 0.5 ? "\uf028" : "\uf027"
        iconColor: Services.Audio.muted ? Theme.mutedForeground : Theme.foreground
        active: audioPopup.shown
        tooltip: Services.Audio.sink ? (Services.Audio.muted ? "Muted" : Services.Audio.volumePercent + "%") : "No audio device"
        onClicked: root.togglePopup(audioPopup)
    }

    Components.IconButton {
        id: powerButton
        anchors.verticalCenter: parent.verticalCenter
        icon: "\uf011"
        active: powerMenu.shown
        tooltip: "Power menu"
        onClicked: root.togglePopup(powerMenu)
    }

    NetworkPopup {
        id: networkPopup
        anchorItem: networkButton
        onPasswordRequired: (network) => {
            networkPopup.shown = false;
            wifiPasswordDialog.network = network;
            wifiPasswordDialog.shown = true;
        }
    }

    WifiPasswordDialog {
        id: wifiPasswordDialog
        screen: root.screenInfo
        onSubmitted: (network, psk) => Services.Network.connectWithPassword(network, psk)
    }

    BluetoothPopup {
        id: bluetoothPopup
        anchorItem: bluetoothButton
    }

    AudioPopup {
        id: audioPopup
        anchorItem: audioButton
    }

    ThemeSwitcher {
        id: themeSwitcher
        anchorItem: themeButton
    }

    PowerMenu {
        id: powerMenu
        anchorItem: powerButton
    }
}
