pragma Singleton
import Quickshell
import Quickshell.Services.UPower

Singleton {
    id: service

    readonly property var device: UPower.displayDevice
    readonly property bool available: device !== null && device !== undefined
        && device.isPresent
        && (device.type === UPowerDeviceType.Battery || device.isLaptopBattery)
    readonly property bool onBattery: UPower.onBattery
    readonly property int percentage: available ? Math.round(device.percentage) : -1
    readonly property int state: device ? device.state : UPowerDeviceState.Unknown
    readonly property bool charging: state === UPowerDeviceState.Charging
        || state === UPowerDeviceState.PendingCharge
    readonly property real timeToEmpty: device ? device.timeToEmpty : 0
    readonly property real timeToFull: device ? device.timeToFull : 0
    readonly property string stateLabel: available
        ? UPowerDeviceState.toString(state)
        : (onBattery ? "On battery" : "AC power")
    readonly property string timeLabel: {
        const seconds = timeToEmpty > 0 ? timeToEmpty : timeToFull;
        if (!available || seconds <= 0)
            return "";
        const minutes = Math.round(seconds / 60);
        const hours = Math.floor(minutes / 60);
        const rest = minutes % 60;
        return hours > 0 ? hours + "h " + rest + "m" : rest + "m";
    }
}
