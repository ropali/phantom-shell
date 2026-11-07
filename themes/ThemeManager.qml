pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Qt.labs.folderlistmodel
import "../config" as Config

Singleton {
    id: manager

    readonly property string builtinDir: Quickshell.shellDir + "/themes/palettes"
    readonly property string customDir: Quickshell.shellDir + "/themes/custom"
    readonly property string presetPath: Quickshell.shellDir + "/themes/presets/default.json"
    readonly property string statePath: Quickshell.statePath("theme.json")

    property var themes: ({})
    property var themeOrder: []
    property string defaultThemeId: "gruvbox"
    property string activeThemeId: "gruvbox"
    property var palette: fallbackPalette
    property string lastError: ""

    signal themeApplied(string id)

    readonly property var fallbackPalette: ({
        id: "gruvbox",
        name: "Gruvbox Dark",
        colors: {
            background: "#282828",
            surface: "#3c3836",
            surfaceElevated: "#504945",
            primary: "#b8bb26",
            secondary: "#fabd2f",
            tertiary: "#83a598",
            foreground: "#fbf1c7",
            mutedForeground: "#a89984",
            disabled: "#665c54",
            border: "#57514e",
            success: "#b8bb26",
            warning: "#fabd2f",
            error: "#fb4934",
            info: "#83a598",
            onPrimary: "#282828",
            onSecondary: "#282828",
            onTertiary: "#282828"
        },
        typography: {
            fontFamily: "JetBrainsMono Nerd Font",
            iconFontFamily: "JetBrainsMono Nerd Font",
            sizeTiny: 9,
            sizeSmall: 10,
            sizeBase: 11,
            sizeMedium: 12,
            size: 13,
            sizeLarge: 16,
            sizeXLarge: 20,
            weightNormal: 400,
            weightMedium: 500,
            weightBold: 700,
            lineHeight: 1.3
        },
        spacing: { xs: 2, sm: 4, md: 8, lg: 12, xl: 16 },
        components: {
            radius: 12,
            radiusSmall: 7,
            radiusLarge: 18,
            borderWidth: 1,
            padding: 12,
            opacity: 0.94,
            buttonSize: 26,
            iconSize: 15,
            trayIconSize: 16,
            workspaceButtonSize: 24,
            controlHeight: 34,
            rowHeight: 30,
            shadow: true
        },
        animation: { fast: 120, normal: 200, slow: 300, easing: "OutCubic" }
    })

    readonly property var availableThemes: {
        const result = [];
        for (let i = 0; i < themeOrder.length; i++) {
            const theme = themes[themeOrder[i]];
            if (theme)
                result.push(theme);
        }
        return result;
    }

    FolderListModel {
        id: builtinFolder
        folder: "file://" + manager.builtinDir
        nameFilters: ["*.json"]
        showDirs: false
    }

    FolderListModel {
        id: customFolder
        folder: "file://" + manager.customDir
        nameFilters: ["*.json"]
        showDirs: false
    }

    readonly property var themeFiles: {
        const result = [];
        manager.collectFiles(builtinFolder, result);
        manager.collectFiles(customFolder, result);
        return result;
    }

    function collectFiles(model, result) {
        for (let i = 0; i < model.count; i++) {
            const name = model.get(i, "fileName");
            if (name && name.endsWith(".json"))
                result.push({ path: model.get(i, "filePath"), name: name });
        }
    }

    Variants {
        model: manager.themeFiles

        delegate: Component {
            ThemeLoader {
                sourcePath: modelData.path
                onThemeLoaded: (theme) => manager.registerTheme(theme)
                onThemeLoadFailed: (path, reason) => {
                    manager.lastError = "Failed to load " + path + ": " + reason;
                    console.warn(manager.lastError);
                }
            }
        }
    }

    FileView {
        id: stateFile
        path: manager.statePath
        blockLoading: true
        watchChanges: false
        printErrors: false
    }

    FileView {
        id: presetFile
        path: manager.presetPath
        blockLoading: true
        watchChanges: false
        printErrors: false
    }

    Timer {
        interval: 3000
        running: true
        repeat: false
        onTriggered: {
            if (!manager.themes[manager.activeThemeId]) {
                manager.activeThemeId = manager.defaultThemeId;
                manager.palette = manager.themes[manager.defaultThemeId] || manager.fallbackPalette;
            }
        }
    }

    Component.onCompleted: {
        manager.loadPreset();
        manager.loadState();
    }

    function loadPreset() {
        try {
            const text = presetFile.text();
            if (text && text.length > 0) {
                const data = JSON.parse(text);
                if (data && typeof data.defaultTheme === "string" && data.defaultTheme.length > 0) {
                    manager.defaultThemeId = data.defaultTheme;
                    if (manager.activeThemeId === "gruvbox")
                        manager.activeThemeId = manager.defaultThemeId;
                }
            }
        } catch (error) {
            manager.lastError = "Failed to read preset: " + error;
            console.warn(manager.lastError);
        }
    }

    function loadState() {
        try {
            const text = stateFile.text();
            if (text && text.length > 0) {
                const data = JSON.parse(text);
                if (data && typeof data.theme === "string" && data.theme.length > 0)
                    manager.activeThemeId = data.theme;
            }
        } catch (error) {
            manager.lastError = "Failed to read saved theme: " + error;
            console.warn(manager.lastError);
        }

        if (manager.themes[manager.activeThemeId])
            manager.palette = manager.themes[manager.activeThemeId];
    }

    function registerTheme(theme) {
        if (!theme || !theme.id)
            return;

        const nextThemes = ({});
        for (const key in manager.themes)
            nextThemes[key] = manager.themes[key];
        nextThemes[theme.id] = theme;

        const nextOrder = manager.themeOrder.slice();
        if (nextOrder.indexOf(theme.id) === -1)
            nextOrder.push(theme.id);
        nextOrder.sort((a, b) => (nextThemes[a].name || a).localeCompare(nextThemes[b].name || b));

        manager.themes = nextThemes;
        manager.themeOrder = nextOrder;

        if (theme.id === manager.activeThemeId)
            manager.palette = theme;
    }

    function applyTheme(id) {
        const theme = manager.themes[id];
        if (!theme) {
            manager.lastError = "Theme not found: " + id;
            console.warn(manager.lastError);
            return false;
        }

        manager.activeThemeId = id;
        manager.palette = theme;
        manager.saveState();
        manager.themeApplied(id);
        manager.runExternalHook(id);
        return true;
    }

    function saveState() {
        try {
            stateFile.setText(JSON.stringify({ theme: manager.activeThemeId }));
        } catch (error) {
            manager.lastError = "Failed to save theme: " + error;
            console.warn(manager.lastError);
        }
    }

    function runExternalHook(id) {
        const hook = Config.Settings.externalThemeHook;
        if (hook && hook.length > 0)
            Quickshell.execDetached(["sh", "-c", hook + " " + id]);
    }

}
