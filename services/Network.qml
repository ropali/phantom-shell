pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking

Singleton {
    id: net

    readonly property var devices: Networking.devices
    readonly property bool wifiEnabled: Networking.wifiEnabled
    readonly property bool wifiHardwareEnabled: Networking.wifiHardwareEnabled
    readonly property int connectivity: Networking.connectivity

    readonly property var wifiDevice: {
        const list = devices ? devices.values : [];
        for (let i = 0; i < list.length; i++) {
            if (list[i] && list[i].type === DeviceType.Wifi)
                return list[i];
        }
        return null;
    }

    property bool scanRequested: false
    readonly property bool scanning: wifiDevice ? wifiDevice.scannerEnabled : false

    property string errorText: ""
    property var attemptNetwork: null

    onWifiDeviceChanged: {
        if (wifiDevice)
            wifiDevice.scannerEnabled = scanRequested;
    }

    onWifiEnabledChanged: {
        if (Networking.wifiEnabled && scanRequested && wifiDevice)
            wifiDevice.scannerEnabled = true;
    }

    Timer {
        id: connectTimeout
        interval: 15000
        onTriggered: {
            if (net.attemptNetwork && !net.attemptNetwork.connected)
                net.errorText = "Could not connect to " + net.attemptNetwork.name + ".";
            net.attemptNetwork = null;
        }
    }

    Connections {
        target: net.attemptNetwork
        function onConnectedChanged() {
            if (net.attemptNetwork && net.attemptNetwork.connected) {
                net.errorText = "";
                net.attemptNetwork = null;
                connectTimeout.stop();
            }
        }
    }

    function setScanning(enabled) {
        scanRequested = enabled;
        if (wifiDevice)
            wifiDevice.scannerEnabled = enabled;
    }

    readonly property bool connected: {
        const list = devices ? devices.values : [];
        for (let i = 0; i < list.length; i++) {
            if (list[i] && list[i].connected)
                return true;
        }
        return false;
    }

    readonly property bool wifiConnected: {
        const list = devices ? devices.values : [];
        for (let i = 0; i < list.length; i++) {
            if (list[i] && list[i].type === DeviceType.Wifi && list[i].connected)
                return true;
        }
        return false;
    }

    readonly property bool wiredConnected: {
        const list = devices ? devices.values : [];
        for (let i = 0; i < list.length; i++) {
            if (list[i] && list[i].type !== DeviceType.Wifi && list[i].connected)
                return true;
        }
        return false;
    }

    // Quickshell's Networking service only enumerates Wi-Fi devices in this
    // build, so wired interfaces are read from NetworkManager directly.
    property var ethernetDevices: []

    readonly property var wiredDevices: ethernetDevices

    Process {
        id: ethernetProcess
        command: ["nmcli", "-t", "-f", "DEVICE,TYPE,STATE,CONNECTION", "device", "status"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: net.parseEthernet(text)
        }
    }

    Process {
        id: ethernetMonitor
        command: ["nmcli", "monitor"]
        running: true

        stdout: SplitParser {
            onRead: ethernetRefreshTimer.restart()
        }
    }

    Timer {
        id: ethernetRefreshTimer
        interval: 250
        onTriggered: net.refreshEthernet()
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: net.refreshEthernet()
    }

    Component.onCompleted: refreshEthernet()

    function refreshEthernet() {
        if (!ethernetProcess.running)
            ethernetProcess.running = true;
    }

    function parseEthernet(output) {
        const result = [];
        if (!output)
            return;
        const lines = output.split("\n");
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i].trim();
            if (line.length === 0)
                continue;
            const parts = line.split(":");
            if (parts.length < 3)
                continue;
            const name = parts[0];
            const type = parts[1];
            const state = parts[2];
            const connection = parts.slice(3).join(":");
            if (type !== "ethernet" && type !== "802-3-ethernet")
                continue;
            if (state === "unmanaged")
                continue;
            const lowerName = name.toLowerCase();
            if (lowerName.startsWith("veth") || lowerName.startsWith("br-")
                || lowerName.startsWith("docker") || lowerName.startsWith("virbr"))
                continue;
            result.push({
                name: name,
                type: type,
                state: state,
                connection: connection,
                connected: state === "connected"
            });
        }
        net.ethernetDevices = result;
    }

    readonly property var networkList: {
        const result = [];
        if (!wifiDevice || !wifiDevice.networks)
            return result;
        const list = wifiDevice.networks.values;
        for (let i = 0; i < list.length; i++) {
            const network = list[i];
            if (!network || !network.name)
                continue;
            result.push(network);
        }
        result.sort((a, b) => {
            if (a.connected !== b.connected)
                return a.connected ? -1 : 1;
            if (b.signalStrength !== a.signalStrength)
                return b.signalStrength - a.signalStrength;
            return (a.name || "").localeCompare(b.name || "");
        });
        return result;
    }

    function isOpenNetwork(network) {
        return network && network.security === WifiSecurityType.Open;
    }

    function requiresPsk(network) {
        if (!network)
            return false;
        return network.security === WifiSecurityType.WpaPsk
            || network.security === WifiSecurityType.Wpa2Psk
            || network.security === WifiSecurityType.Sae;
    }

    function securityLabel(network) {
        return network ? WifiSecurityType.toString(network.security) : "";
    }

    function stateLabel(network) {
        return network ? ConnectionState.toString(network.state) : "";
    }

    function toggleWifi() {
        Networking.wifiEnabled = !Networking.wifiEnabled;
    }

    function setWifiEnabled(enabled) {
        Networking.wifiEnabled = enabled;
    }

    function clearError() {
        errorText = "";
    }

    function connectNetwork(network) {
        if (!network || network.connected)
            return;
        errorText = "";
        if (network.known || isOpenNetwork(network)) {
            attemptNetwork = network;
            connectTimeout.restart();
            network.connect();
        }
    }

    function connectWithPassword(network, password) {
        if (!network || !password || password.length === 0)
            return;
        errorText = "";
        attemptNetwork = network;
        connectTimeout.restart();
        network.connectWithPsk(password);
    }

    function disconnectNetwork(network) {
        if (network && network.connected)
            network.disconnect();
    }
}
