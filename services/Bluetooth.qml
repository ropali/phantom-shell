pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
    id: service

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null && adapter !== undefined
    readonly property bool enabled: available ? adapter.enabled : false

    readonly property var deviceList: {
        const result = [];
        if (!available || !adapter.devices)
            return result;
        const list = adapter.devices.values;
        for (let i = 0; i < list.length; i++) {
            const device = list[i];
            if (!device || device.blocked)
                continue;
            if (!device.name && !device.deviceName && !device.address)
                continue;
            result.push(device);
        }
        result.sort((a, b) => {
            if (a.connected !== b.connected)
                return a.connected ? -1 : 1;
            if (a.paired !== b.paired)
                return a.paired ? -1 : 1;
            return service.deviceLabel(a).localeCompare(service.deviceLabel(b));
        });
        return result;
    }


    readonly property int connectedCount: {
        const list = deviceList;
        let count = 0;
        for (let i = 0; i < list.length; i++) {
            if (list[i].connected)
                count++;
        }
        return count;
    }

    readonly property string connectedDeviceLabel: {
        const list = deviceList;
        for (let i = 0; i < list.length; i++) {
            if (list[i].connected)
                return service.deviceLabel(list[i]);
        }
        return "";
    }

    property bool discoveringRequested: false
    property var pendingConnectDevice: null
    property var attemptDevice: null
    property string errorText: ""

    onAdapterChanged: {
        if (available)
            adapter.discovering = discoveringRequested;
    }

    Connections {
        target: service.pendingConnectDevice
        function onPairedChanged() {
            if (!service.pendingConnectDevice)
                return;
            if (service.pendingConnectDevice.paired) {
                service.attemptDevice = service.pendingConnectDevice;
                connectTimeout.restart();
                service.pendingConnectDevice.connect();
                service.pendingConnectDevice = null;
            }
        }
    }

    Timer {
        id: pairTimeout
        interval: 20000
        onTriggered: {
            if (service.pendingConnectDevice && !service.pendingConnectDevice.paired)
                service.errorText = "Could not pair with " + service.deviceLabel(service.pendingConnectDevice) + ".";
            service.pendingConnectDevice = null;
        }
    }

    Timer {
        id: connectTimeout
        interval: 15000
        onTriggered: {
            if (service.attemptDevice && !service.attemptDevice.connected)
                service.errorText = "Could not connect to " + service.deviceLabel(service.attemptDevice)
                    + ". Make sure it is on and in range.";
            service.attemptDevice = null;
        }
    }

    Connections {
        target: service.attemptDevice
        function onConnectedChanged() {
            if (service.attemptDevice && service.attemptDevice.connected) {
                service.errorText = "";
                service.attemptDevice = null;
                connectTimeout.stop();
            }
        }
    }

    onPendingConnectDeviceChanged: {
        if (pendingConnectDevice)
            pairTimeout.restart();
        else
            pairTimeout.stop();
    }

    function setDiscovering(enabled) {
        discoveringRequested = enabled;
        if (available)
            adapter.discovering = enabled;
    }

    function deviceLabel(device) {
        if (!device)
            return "";
        return device.name || device.deviceName || device.address || "Unknown device";
    }

    function deviceStateLabel(device) {
        if (!device)
            return "";
        if (device.pairing)
            return "Pairing…";
        return BluetoothDeviceState.toString(device.state);
    }

    function isConnecting(device) {
        return device !== null && device.state === BluetoothDeviceState.Connecting;
    }

    function clearError() {
        errorText = "";
    }

    function toggle() {
        if (available)
            adapter.enabled = !adapter.enabled;
    }

    function toggleDevice(device) {
        if (!device)
            return;
        errorText = "";
        if (device.connected) {
            device.disconnect();
            return;
        }
        if (device.paired || device.bonded) {
            attemptDevice = device;
            connectTimeout.restart();
            device.connect();
            return;
        }
        pendingConnectDevice = device;
        device.pair();
    }
}
