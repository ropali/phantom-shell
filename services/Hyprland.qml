pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland as Hypr

Singleton {
    id: service

    readonly property var workspaces: Hypr.Hyprland.workspaces
    readonly property var focusedWorkspace: Hypr.Hyprland.focusedWorkspace
    readonly property var monitors: Hypr.Hyprland.monitors

    property int gapsOutTop: 10
    property int gapsOutBottom: 10

    Process {
        id: gapsProcess
        command: ["hyprctl", "getoption", "general:gaps_out", "-j"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: service.parseGapsOut(text)
        }
    }

    Connections {
        target: Hypr.Hyprland
        function onRawEvent(event) {
            if (String(event.name).toLowerCase().indexOf("config") !== -1)
                service.refreshGaps();
        }
    }

    function refreshGaps() {
        if (!gapsProcess.running)
            gapsProcess.running = true;
    }

    function parseGapsOut(output) {
        try {
            const data = JSON.parse(output);
            const parts = String(data.css || "").trim().split(/\s+/).map(Number).filter(n => !isNaN(n));
            if (parts.length === 0)
                return;
            let top = parts[0];
            let bottom = parts[0];
            if (parts.length === 2) {
                top = parts[0];
                bottom = parts[0];
            } else if (parts.length === 3) {
                top = parts[0];
                bottom = parts[2];
            } else if (parts.length >= 4) {
                top = parts[0];
                bottom = parts[2];
            }
            service.gapsOutTop = top;
            service.gapsOutBottom = bottom;
        } catch (error) {
            console.warn("Failed to parse Hyprland gaps_out:", error);
        }
    }

    function switchTo(id) {
        Hypr.Hyprland.dispatch("hl.dsp.focus({ workspace = " + id + " })");
    }
}
