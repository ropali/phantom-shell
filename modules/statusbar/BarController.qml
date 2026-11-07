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
    property var networkAnchor: null
    property var bluetoothAnchor: null
    property var audioAnchor: null
    property var powerAnchor: null
    property var controlCenterAnchor: null

    function togglePopup(popup) {
        const wasOpen = popup.shown;
        Services.UiState.dismissAll();
        popup.shown = !wasOpen;
    }

    function registerButton(id, item) {
        if (id === "controlCenter")
            controller.controlCenterButton = item;
        else if (id === "network")
            controller.networkButton = item;
        else if (id === "bluetooth")
            controller.bluetoothButton = item;
        else if (id === "audio")
            controller.audioButton = item;
        else if (id === "power")
            controller.powerButton = item;
        else
            return;

        Qt.callLater(controller.updateAnchors);
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

    function updateAnchor(button, anchor) {
        const bar = controller.parent;
        if (!button || !anchor || !bar)
            return;

        const pos = button.mapToItem(bar, 0, 0);
        anchor.x = pos.x;
        anchor.y = pos.y;
        anchor.width = button.width;
        anchor.height = button.height;
    }

    function updateAnchors() {
        controller.updateAnchor(controller.networkButton, controller.networkAnchor);
        controller.updateAnchor(controller.bluetoothButton, controller.bluetoothAnchor);
        controller.updateAnchor(controller.audioButton, controller.audioAnchor);
        controller.updateAnchor(controller.powerButton, controller.powerAnchor);
        controller.updateAnchor(controller.controlCenterButton, controller.controlCenterAnchor);
    }

    function updateControlCenterAnchor(reanchor) {
        controller.updateAnchors();

        if (reanchor && controlCenter.shown) {
            controlCenter.reanchoring = true;
            controlCenter.shown = false;
            reanchorTimer.detail = controlCenter.detailId;
            reanchorTimer.restart();
        }
    }

    function reanchorControlCenter() {
        controller.updateControlCenterAnchor(true);
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
            ? controller.controlCenterAnchor
            : (controller.powerButton ? controller.powerAnchor : controller.controlCenterAnchor);
        controller.togglePopup(powerMenu);
    }

    NetworkPopup {
        id: networkPopup
        anchorItem: controller.networkAnchor
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
        anchorItem: controller.bluetoothAnchor
    }

    AudioPopup {
        id: audioPopup
        anchorItem: controller.audioAnchor
    }

    PowerMenu {
        id: powerMenu
        anchorItem: controller.powerMenuAnchor
    }

    ControlCenter {
        id: controlCenter
        anchorItem: controller.controlCenterAnchor
        onPasswordRequired: (network) => {
            controlCenter.shown = false;
            wifiPasswordDialog.network = network;
            wifiPasswordDialog.shown = true;
        }
        onPowerRequested: controller.togglePowerMenu(true)
    }
}
