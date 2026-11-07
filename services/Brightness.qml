pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: service

    property bool available: false
    property int percent: 0

    Process {
        id: readProcess
        command: ["brightnessctl", "-m", "-c", "backlight"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: service.parse(text)
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                service.available = false;
                service.percent = 0;
            }
        }
    }

    Process {
        id: writeProcess
        running: false
        onExited: (exitCode, exitStatus) => service.refresh()
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: service.refresh()
    }

    Component.onCompleted: refresh()

    function refresh() {
        if (!readProcess.running)
            readProcess.running = true;
    }

    function parse(output) {
        const line = (output || "").trim().split("\n")[0] || "";
        if (!line) {
            available = false;
            return;
        }
        const parts = line.split(",");
        if (parts.length < 5) {
            available = false;
            return;
        }
        const value = parseInt(parts[3], 10);
        if (isNaN(value)) {
            available = false;
            return;
        }
        available = true;
        percent = Math.max(0, Math.min(100, value));
    }

    function setPercent(value) {
        if (!available)
            return;
        const next = Math.max(0, Math.min(100, Math.round(value)));
        percent = next;
        writeProcess.command = ["brightnessctl", "-c", "backlight", "set", next + "%"];
        if (!writeProcess.running)
            writeProcess.running = true;
    }
}
