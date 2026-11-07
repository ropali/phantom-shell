pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../config" as Config

Singleton {
    id: service

    readonly property string directory: Quickshell.env("HOME") + "/Pictures/wallpapers"
    readonly property string statePath: Quickshell.statePath("wallpaper.json")

    property var files: []
    property string currentPath: Config.Settings.wallpaperPath

    Process {
        id: listProcess
        command: ["sh", "-c",
            "find \"$HOME/Pictures/wallpapers\" -type f "
            + "\\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' "
            + "-o -iname '*.webp' \\) | sort"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: service.parseFiles(text)
        }
    }

    FileView {
        id: stateFile
        path: service.statePath
        blockLoading: true
        watchChanges: false
        printErrors: false
    }

    Component.onCompleted: {
        loadState();
        refresh();
    }

    function loadState() {
        try {
            const text = stateFile.text();
            if (text && text.length > 0) {
                const data = JSON.parse(text);
                if (data && typeof data.path === "string" && data.path.length > 0) {
                    currentPath = data.path;
                    Config.Settings.wallpaperPath = data.path;
                }
            }
        } catch (error) {
            console.warn("Failed to read wallpaper state:", error);
        }
    }

    function saveState() {
        try {
            stateFile.setText(JSON.stringify({ path: currentPath }));
        } catch (error) {
            console.warn("Failed to save wallpaper state:", error);
        }
    }

    function refresh() {
        if (!listProcess.running)
            listProcess.running = true;
    }

    function parseFiles(output) {
        const result = [];
        const lines = (output || "").split("\n");
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i].trim();
            if (line.length > 0)
                result.push(line);
        }
        files = result;
    }

    function setWallpaper(path) {
        if (!path || path === currentPath)
            return;
        currentPath = path;
        Config.Settings.wallpaperPath = path;
        saveState();
    }

    function name(path) {
        return path ? path.split("/").pop() : "";
    }
}
