pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: service

    // Software warm overlay. It works without hyprsunset or a gamma daemon.
    property bool enabled: false
    property int temperature: 4000

    readonly property bool available: true
    readonly property real opacity: enabled
        ? Math.max(0, Math.min(0.28, (6500 - temperature) / 3800 * 0.28))
        : 0

    function toggle() {
        enabled = !enabled;
    }

    function setTemperature(value) {
        temperature = Math.max(2700, Math.min(6500, value));
        enabled = true;
    }
}
