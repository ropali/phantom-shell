import QtQuick
import "../../services" as Services
import "../controlcenter"

Item {
    id: controller

    width: 0
    height: 0

    property var screenInfo: null
    property var controlCenterButton: null
    property var networkButton: null
    property var bluetoothButton: null
    property var audioButton: null
    property var powerButton: null
    property var powerMenuAnchor: null

    function togglePopup(popup) {
        const wasOpen = popup.shown;
        Services.UiState.dismissAll();
        popup.shown = !wasOpen;
    }

    function registerButton(id, item) {
        if (id === "controlCenter") {
            controller.controlCenterButton = item;
            Qt.callLater(controller.reanchorControlCenter);
        } else if (id === "network") {
            controller.networkButton = item;
        } else if (id === "bluetooth") {
            controller.bluetoothButton = item;
        } else if (id === "audio") {
            controller.audioButton = item;
        } else if (id === "power") {
            controller.powerButton = item;
        }
    }

    function unregisterButton(id, item) {
        if (id === "controlCenter" && controller.controlCenterButton === item)
            controller.controlCenterButton = null;
        else if (id === "network" && controller.networkButton === item)
            controller.networkButton = null;
        else if (id === "bluetooth" && controller.bluetoothButton === item)
            controller.bluetoothButton = null;
        else if (id === "audio" && controller.audioButton === item)
            controller.audioButton = null;
        else if (id === "power" && controller.powerButton === item)
            controller.powerButton = null;
    }

    function reanchorControlCenter() {
        if (reanchorTimer.running || controlCenter.reanchoring)
            return;
        if (!controlCenter.shown)
            return;
        controlCenter.reanchoring = true;
        reanchorTimer.detail = controlCenter.detailId;
        controlCenter.shown = false;
        reanchorTimer.restart();
    }

    Timer {
        id: reanchorTimer
        interval: 60
        repeat: false
        property string detail: ""

        onTriggered: {
            controlCenter.detailId = detail;
            controlCenter.shown = true;
            controlCenter.reanchoring = false;
        }
    }

    function isOpen(id) {
        if (id === "controlCenter")
            return controlCenter.shown;
        if (id === "network")
            return networkPopup.shown;
        if (id === "bluetooth")
            return bluetoothPopup.shown;
        if (id === "audio")
            return audioPopup.shown;
        if (id === "power")
            return powerMenu.shown;
        return false;
    }

    function toggleControlCenter() {
        controller.togglePopup(controlCenter);
    }

    function toggleNetwork() {
        controller.togglePopup(networkPopup);
    }

    function toggleBluetooth() {
        controller.togglePopup(bluetoothPopup);
    }

    function toggleAudio() {
        controller.togglePopup(audioPopup);
    }

    function togglePowerMenu(fromControlCenter) {
        controller.powerMenuAnchor = fromControlCenter
            ? controller.controlCenterButton
            : (controller.powerButton || controller.controlCenterButton);
        controller.togglePopup(powerMenu);
    }

    NetworkPopup {
        id: networkPopup
        anchorItem: controller.networkButton
        onPasswordRequired: (network) => {
            networkPopup.shown = false;
            wifiPasswordDialog.network = network;
            wifiPasswordDialog.shown = true;
        }
    }

    WifiPasswordDialog {
        id: wifiPasswordDialog
        screen: controller.screenInfo
        onSubmitted: (network, psk) => Services.Network.connectWithPassword(network, psk)
    }

    BluetoothPopup {
        id: bluetoothPopup
        anchorItem: controller.bluetoothButton
    }

    AudioPopup {
        id: audioPopup
        anchorItem: controller.audioButton
    }

    PowerMenu {
        id: powerMenu
        anchorItem: controller.powerMenuAnchor
    }

    ControlCenter {
        id: controlCenter
        anchorItem: controller.controlCenterButton
        onPasswordRequired: (network) => {
            controlCenter.shown = false;
            wifiPasswordDialog.network = network;
            wifiPasswordDialog.shown = true;
        }
        onPowerRequested: controller.togglePowerMenu(true)
    }
}
