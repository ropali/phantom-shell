pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: settings

    // Bar geometry and placement. Visual tokens live in themes/.
    property bool barVisible: true
    property int barHeight: 34

    // Percentage of the monitor width occupied by the bar. 80 means the bar
    // spans 80% of the screen, leaving 10% free on each side.
    property int barWidthPercent: 60

    // Minimum gap between the bar and the left/right screen edges. The bar is
    // clamped so it never gets closer than this even with barWidthPercent 100.
    property int edgeGap: 24

    property int screenMargin: 4
    property string barPosition: "top"
    property string barAlignment: "center"

    // Visible gap between the bar and tiled windows. Hyprland's gaps_out is
    // compensated automatically, so changing gaps_out does not change this
    // value. Set to 0 for windows to touch the bar.
    property int barWindowGap: 10

    // Workspaces
    property int workspaceMinCount: 0
    property int workspaceMaxCount: 10

    // Date and time. The override strings win when non-empty.
    property string dateFormatOverride: ""
    property string timeFormatOverride: ""
    property bool dateShow: true
    property bool clockShow: true
    property bool dateShowWeekday: true
    property bool dateShowYear: false
    property bool clockUse24Hour: false
    property bool clockShowSeconds: false
    property bool clockShowAmPm: true
    property string dateTimeOrder: "date-first"

    readonly property string dateFormat: {
        if (dateFormatOverride.length > 0)
            return dateFormatOverride;
        const parts = [];
        if (dateShowWeekday)
            parts.push("ddd");
        parts.push("MMM dd");
        if (dateShowYear)
            parts.push("yyyy");
        return parts.join(", ");
    }

    readonly property string timeFormat: {
        if (timeFormatOverride.length > 0)
            return timeFormatOverride;
        if (clockUse24Hour)
            return clockShowSeconds ? "HH:mm:ss" : "HH:mm";
        return "hh:mm" + (clockShowSeconds ? ":ss" : "")
            + (clockShowAmPm ? " AP" : "");
    }

    // Temporary static wallpaper surface used while Noctalia is not running.
    // The full wallpaper module is scheduled for Milestone 6.
    property string wallpaperPath: Quickshell.env("HOME") + "/Pictures/wallpapers/Gruv/stairs.jpg"
    property string wallpaperDirectory: Quickshell.env("HOME") + "/Pictures/wallpapers"
    property string wallpaperScaling: "crop"
    property int wallpaperTransition: 300

    // Optional command run after a theme change, e.g. a script that updates
    // Hyprland borders, GTK, Qt or the icon theme. It is executed detached and
    // cannot break the Quickshell theme switch if it fails.
    property string externalThemeHook: ""

    // Optional weather location for the calendar flyout. Empty uses the
    // IP-based location through wttr.in.
    property string weatherLocation: ""

    // Calendar
    property int calendarFirstDay: 1
    property bool calendarShowWeekNumbers: true
    property bool calendarShowAdjacentMonths: true
    property bool calendarHighlightToday: true
    property bool calendarShowWeather: true
    property int calendarWidth: 440
    property int calendarCellHeight: 36

    // Global settings window
    property int settingsWidth: 1040
    property int settingsHeight: 700
    property int settingsSidebarPercent: 30

    // Appearance overrides on top of the active theme.
    property string fontFamilyOverride: ""
    property real uiScale: 1.0
    property real radiusScale: 1.0
    property real shellOpacity: 0.94
    property bool animationsEnabled: true
    property real animationScale: 1.0

    // Status bar control layout. The system tray, the configurable controls
    // and the control center button form a single group. The group can be
    // placed on the left or right side of the bar.
    readonly property var defaultBarLayout: [
        { id: "notifications", visible: true },
        { id: "network", visible: true },
        { id: "bluetooth", visible: true },
        { id: "audio", visible: true },
        { id: "power", visible: true }
    ]

    property var barLayout: defaultBarLayout
    property string barControlCenterPosition: "right"
    property string barStyle: "classic"

    // Apps shown in the pinned-apps pill of the pill layout.
    property var pinnedApps: [
        { icon: "\uf120", label: "Terminal", command: "ghostty", color: "info" },
        { icon: "\uf268", label: "Chrome", command: "google-chrome-stable --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations", color: "warning" },
        { icon: "\uf07b", label: "Files", command: "dolphin", color: "secondary" },
        { icon: "\uf1bc", label: "Spotify", command: "spotify", color: "success" },
        { icon: "\uf392", label: "Discord", command: "discord", color: "tertiary" }
    ]

    // Control center quick cards.
    readonly property var defaultControlCenterWidgets: [
        { id: "wifi", visible: true },
        { id: "bluetooth", visible: true },
        { id: "power", visible: true },
        { id: "nightlight", visible: true },
        { id: "dnd", visible: true },
        { id: "microphone", visible: true }
    ]

    property var controlCenterWidgets: defaultControlCenterWidgets
    property int controlCenterColumns: 2
    property int controlCenterWidth: 440
    property int controlCenterSpacing: 12
    property bool controlCenterShowMedia: true
    property bool controlCenterShowSliders: true
    property bool controlCenterShowThemeWallpaper: true

    readonly property string barStatePath: Quickshell.statePath("bar.json")
    readonly property string settingsStatePath: Quickshell.statePath("settings.json")

    property string lastSettingsError: ""

    FileView {
        id: barStateFile
        path: settings.barStatePath
        blockLoading: true
        watchChanges: false
        printErrors: false
    }

    FileView {
        id: settingsFile
        path: settings.settingsStatePath
        blockLoading: true
        watchChanges: false
        printErrors: false
    }

    Timer {
        id: saveTimer
        interval: 350
        repeat: false
        onTriggered: settings.writeSettings()
    }

    Component.onCompleted: {
        settings.loadBarState();
        settings.loadSettings();
    }

    Component.onDestruction: settings.writeSettings()

    function clampInt(value, minimum, maximum, fallback) {
        const number = Number(value);
        if (!isFinite(number))
            return fallback;
        return Math.max(minimum, Math.min(maximum, Math.round(number)));
    }

    function clampReal(value, minimum, maximum, fallback) {
        const number = Number(value);
        if (!isFinite(number))
            return fallback;
        return Math.max(minimum, Math.min(maximum, number));
    }

    function readBool(data, key, fallback) {
        return data && typeof data[key] === "boolean" ? data[key] : fallback;
    }

    function readString(data, key, fallback) {
        return data && typeof data[key] === "string" ? data[key] : fallback;
    }

    function readInt(data, key, fallback, minimum, maximum) {
        return clampInt(data ? data[key] : undefined, minimum, maximum, fallback);
    }

    function readReal(data, key, fallback, minimum, maximum) {
        return clampReal(data ? data[key] : undefined, minimum, maximum, fallback);
    }

    function sanitizeBarLayout(items) {
        const known = {
            notifications: true,
            network: true,
            bluetooth: true,
            audio: true,
            power: true
        };
        const seen = ({});
        const result = [];
        if (Array.isArray(items)) {
            for (let i = 0; i < items.length; i++) {
                const item = items[i];
                if (!item || !known[item.id] || seen[item.id])
                    continue;
                seen[item.id] = true;
                result.push({
                    id: item.id,
                    visible: item.visible !== false
                });
            }
        }
        for (let i = 0; i < defaultBarLayout.length; i++) {
            const item = defaultBarLayout[i];
            if (!seen[item.id])
                result.push({
                    id: item.id,
                    visible: item.visible
                });
        }
        return result;
    }

    function sanitizeControlCenterWidgets(items) {
        const known = {
            wifi: true,
            bluetooth: true,
            power: true,
            nightlight: true,
            dnd: true,
            microphone: true
        };
        const seen = ({});
        const result = [];
        if (Array.isArray(items)) {
            for (let i = 0; i < items.length; i++) {
                const item = items[i];
                if (!item || !known[item.id] || seen[item.id])
                    continue;
                seen[item.id] = true;
                result.push({
                    id: item.id,
                    visible: item.visible !== false
                });
            }
        }
        for (let i = 0; i < defaultControlCenterWidgets.length; i++) {
            const item = defaultControlCenterWidgets[i];
            if (!seen[item.id])
                result.push({
                    id: item.id,
                    visible: item.visible
                });
        }
        return result;
    }

    function loadBarState() {
        try {
            const text = barStateFile.text();
            if (!text || text.length === 0)
                return;
            const data = JSON.parse(text);
            if (!data || typeof data !== "object")
                return;

            if (Array.isArray(data.items))
                barLayout = sanitizeBarLayout(data.items);
            else if (typeof data === "object") {
                const migrated = [];
                for (let i = 0; i < defaultBarLayout.length; i++) {
                    const item = defaultBarLayout[i];
                    migrated.push({
                        id: item.id,
                        visible: typeof data[item.id] === "boolean"
                            ? data[item.id] : item.visible
                    });
                }
                barLayout = migrated;
            }

            barVisible = readBool(data, "visible", barVisible);
            barHeight = readInt(data, "height", barHeight, 24, 64);
            barWidthPercent = readInt(data, "widthPercent", barWidthPercent, 20, 100);
            edgeGap = readInt(data, "edgeGap", edgeGap, 0, 400);
            screenMargin = readInt(data, "screenMargin", screenMargin, 0, 32);
            barWindowGap = readInt(data, "barWindowGap", barWindowGap, 0, 64);
            const position = readString(data, "barPosition", barPosition);
            barPosition = position === "bottom" ? "bottom" : "top";
            const alignment = readString(data, "alignment", barAlignment);
            barAlignment = alignment === "left" || alignment === "right"
                ? alignment : "center";
            barControlCenterPosition = data.position === "left" ? "left" : "right";
            barStyle = data.style === "pills" ? "pills" : "classic";
        } catch (error) {
            console.warn("Failed to read bar settings:", error);
        }
    }

    function saveBarState() {
        try {
            barStateFile.setText(JSON.stringify({
                style: barStyle,
                position: barControlCenterPosition,
                visible: barVisible,
                height: barHeight,
                widthPercent: barWidthPercent,
                edgeGap: edgeGap,
                screenMargin: screenMargin,
                barWindowGap: barWindowGap,
                barPosition: barPosition,
                alignment: barAlignment,
                items: barLayout
            }));
        } catch (error) {
            console.warn("Failed to save bar settings:", error);
        }
    }

    function loadSettings() {
        try {
            const text = settingsFile.text();
            if (!text || text.length === 0)
                return;
            const data = JSON.parse(text);
            if (!data || typeof data !== "object")
                return;

            dateFormatOverride = readString(data, "dateFormatOverride", dateFormatOverride);
            timeFormatOverride = readString(data, "timeFormatOverride", timeFormatOverride);
            dateShow = readBool(data, "dateShow", dateShow);
            clockShow = readBool(data, "clockShow", clockShow);
            dateShowWeekday = readBool(data, "dateShowWeekday", dateShowWeekday);
            dateShowYear = readBool(data, "dateShowYear", dateShowYear);
            clockUse24Hour = readBool(data, "clockUse24Hour", clockUse24Hour);
            clockShowSeconds = readBool(data, "clockShowSeconds", clockShowSeconds);
            clockShowAmPm = readBool(data, "clockShowAmPm", clockShowAmPm);
            dateTimeOrder = readString(data, "dateTimeOrder", dateTimeOrder) === "time-first"
                ? "time-first" : "date-first";

            wallpaperDirectory = readString(data, "wallpaperDirectory", wallpaperDirectory);
            if (wallpaperDirectory.length === 0)
                wallpaperDirectory = Quickshell.env("HOME") + "/Pictures/wallpapers";
            const scaling = readString(data, "wallpaperScaling", wallpaperScaling);
            wallpaperScaling = ["crop", "fit", "stretch", "center"].indexOf(scaling) >= 0
                ? scaling : "crop";
            wallpaperTransition = readInt(data, "wallpaperTransition", wallpaperTransition, 0, 1000);
            externalThemeHook = readString(data, "externalThemeHook", externalThemeHook);
            weatherLocation = readString(data, "weatherLocation", weatherLocation);

            calendarFirstDay = readInt(data, "calendarFirstDay", calendarFirstDay, 0, 1);
            calendarShowWeekNumbers = readBool(data, "calendarShowWeekNumbers", calendarShowWeekNumbers);
            calendarShowAdjacentMonths = readBool(data, "calendarShowAdjacentMonths", calendarShowAdjacentMonths);
            calendarHighlightToday = readBool(data, "calendarHighlightToday", calendarHighlightToday);
            calendarShowWeather = readBool(data, "calendarShowWeather", calendarShowWeather);
            calendarWidth = readInt(data, "calendarWidth", calendarWidth, 340, 640);
            calendarCellHeight = readInt(data, "calendarCellHeight", calendarCellHeight, 28, 48);

            settingsWidth = readInt(data, "settingsWidth", settingsWidth, 720, 1600);
            settingsHeight = readInt(data, "settingsHeight", settingsHeight, 520, 1100);
            settingsSidebarPercent = readInt(data, "settingsSidebarPercent", settingsSidebarPercent, 22, 42);

            fontFamilyOverride = readString(data, "fontFamilyOverride", fontFamilyOverride);
            uiScale = readReal(data, "uiScale", uiScale, 0.8, 1.3);
            radiusScale = readReal(data, "radiusScale", radiusScale, 0.5, 1.6);
            shellOpacity = readReal(data, "shellOpacity", shellOpacity, 0.5, 1.0);
            animationsEnabled = readBool(data, "animationsEnabled", animationsEnabled);
            animationScale = readReal(data, "animationScale", animationScale, 0.5, 2.0);

            controlCenterWidgets = sanitizeControlCenterWidgets(data.controlCenterWidgets);
            controlCenterColumns = readInt(data, "controlCenterColumns", controlCenterColumns, 2, 3);
            controlCenterWidth = readInt(data, "controlCenterWidth", controlCenterWidth, 360, 680);
            controlCenterSpacing = readInt(data, "controlCenterSpacing", controlCenterSpacing, 4, 24);
            controlCenterShowMedia = readBool(data, "controlCenterShowMedia", controlCenterShowMedia);
            controlCenterShowSliders = readBool(data, "controlCenterShowSliders", controlCenterShowSliders);
            controlCenterShowThemeWallpaper = readBool(data, "controlCenterShowThemeWallpaper", controlCenterShowThemeWallpaper);
        } catch (error) {
            lastSettingsError = "Failed to read settings: " + error;
            console.warn(lastSettingsError);
        }
    }

    function settingsData() {
        return {
            dateFormatOverride: dateFormatOverride,
            timeFormatOverride: timeFormatOverride,
            dateShow: dateShow,
            clockShow: clockShow,
            dateShowWeekday: dateShowWeekday,
            dateShowYear: dateShowYear,
            clockUse24Hour: clockUse24Hour,
            clockShowSeconds: clockShowSeconds,
            clockShowAmPm: clockShowAmPm,
            dateTimeOrder: dateTimeOrder,
            wallpaperDirectory: wallpaperDirectory,
            wallpaperScaling: wallpaperScaling,
            wallpaperTransition: wallpaperTransition,
            externalThemeHook: externalThemeHook,
            weatherLocation: weatherLocation,
            calendarFirstDay: calendarFirstDay,
            calendarShowWeekNumbers: calendarShowWeekNumbers,
            calendarShowAdjacentMonths: calendarShowAdjacentMonths,
            calendarHighlightToday: calendarHighlightToday,
            calendarShowWeather: calendarShowWeather,
            calendarWidth: calendarWidth,
            calendarCellHeight: calendarCellHeight,
            settingsWidth: settingsWidth,
            settingsHeight: settingsHeight,
            settingsSidebarPercent: settingsSidebarPercent,
            fontFamilyOverride: fontFamilyOverride,
            uiScale: uiScale,
            radiusScale: radiusScale,
            shellOpacity: shellOpacity,
            animationsEnabled: animationsEnabled,
            animationScale: animationScale,
            controlCenterWidgets: controlCenterWidgets,
            controlCenterColumns: controlCenterColumns,
            controlCenterWidth: controlCenterWidth,
            controlCenterSpacing: controlCenterSpacing,
            controlCenterShowMedia: controlCenterShowMedia,
            controlCenterShowSliders: controlCenterShowSliders,
            controlCenterShowThemeWallpaper: controlCenterShowThemeWallpaper
        };
    }

    function writeSettings() {
        try {
            settingsFile.setText(JSON.stringify(settingsData()));
        } catch (error) {
            lastSettingsError = "Failed to save settings: " + error;
            console.warn(lastSettingsError);
        }
    }

    function scheduleSave() {
        saveTimer.restart();
    }

    function saveSettingsNow() {
        saveTimer.stop();
        writeSettings();
    }

    function barVisibleItems() {
        const result = [];
        for (let i = 0; i < barLayout.length; i++) {
            const item = barLayout[i];
            if (item.visible)
                result.push(item);
        }
        return result;
    }

    function updateBarItem(id, changes) {
        const next = [];
        for (let i = 0; i < barLayout.length; i++) {
            const item = barLayout[i];
            if (item.id !== id) {
                next.push(item);
                continue;
            }
            const updated = {};
            for (const key in item)
                updated[key] = item[key];
            for (const key in changes)
                updated[key] = changes[key];
            next.push(updated);
        }
        barLayout = next;
        saveBarState();
    }

    function setBarItemVisible(id, visible) {
        updateBarItem(id, { visible: visible });
    }

    function setBarControlCenterPosition(position) {
        barControlCenterPosition = position === "left" ? "left" : "right";
        saveBarState();
    }

    function setBarStyle(style) {
        barStyle = style === "pills" ? "pills" : "classic";
        saveBarState();
    }

    function setBarVisible(visible) {
        barVisible = visible === true;
        saveBarState();
    }

    function setBarHeight(value) {
        barHeight = clampInt(value, 24, 64, barHeight);
        saveBarState();
    }

    function setBarWidthPercent(value) {
        barWidthPercent = clampInt(value, 20, 100, barWidthPercent);
        saveBarState();
    }

    function setEdgeGap(value) {
        edgeGap = clampInt(value, 0, 400, edgeGap);
        saveBarState();
    }

    function setScreenMargin(value) {
        screenMargin = clampInt(value, 0, 32, screenMargin);
        saveBarState();
    }

    function setBarWindowGap(value) {
        barWindowGap = clampInt(value, 0, 64, barWindowGap);
        saveBarState();
    }

    function setBarPosition(position) {
        barPosition = position === "bottom" ? "bottom" : "top";
        saveBarState();
    }

    function setBarAlignment(alignment) {
        barAlignment = alignment === "left" || alignment === "right"
            ? alignment : "center";
        saveBarState();
    }

    function isBarItemVisible(id) {
        for (let i = 0; i < barLayout.length; i++) {
            if (barLayout[i].id === id)
                return barLayout[i].visible;
        }
        return true;
    }

    function moveBarItem(from, to) {
        if (from === to || from < 0 || to < 0
            || from >= barLayout.length || to >= barLayout.length)
            return;
        const next = barLayout.slice();
        const moved = next.splice(from, 1)[0];
        next.splice(to, 0, moved);
        barLayout = next;
        saveBarState();
    }

    function moveBarItemRelative(sourceId, targetId, after) {
        let from = -1;
        for (let i = 0; i < barLayout.length; i++) {
            if (barLayout[i].id === sourceId) {
                from = i;
                break;
            }
        }
        if (from < 0 || sourceId === targetId)
            return;

        const next = barLayout.slice();
        const moved = next.splice(from, 1)[0];

        let targetIndex = -1;
        for (let i = 0; i < next.length; i++) {
            if (next[i].id === targetId) {
                targetIndex = i;
                break;
            }
        }
        if (targetIndex < 0)
            return;

        next.splice(after ? targetIndex + 1 : targetIndex, 0, moved);
        barLayout = next;
        saveBarState();
    }

    function controlCenterVisibleWidgets() {
        const result = [];
        for (let i = 0; i < controlCenterWidgets.length; i++) {
            const item = controlCenterWidgets[i];
            if (item.visible)
                result.push(item);
        }
        return result;
    }

    function updateControlCenterWidget(id, changes) {
        const next = [];
        for (let i = 0; i < controlCenterWidgets.length; i++) {
            const item = controlCenterWidgets[i];
            if (item.id !== id) {
                next.push(item);
                continue;
            }
            const updated = {};
            for (const key in item)
                updated[key] = item[key];
            for (const key in changes)
                updated[key] = changes[key];
            next.push(updated);
        }
        controlCenterWidgets = next;
        scheduleSave();
    }

    function setControlCenterWidgetVisible(id, visible) {
        updateControlCenterWidget(id, { visible: visible });
    }

    function moveControlCenterWidget(from, to) {
        if (from === to || from < 0 || to < 0
            || from >= controlCenterWidgets.length || to >= controlCenterWidgets.length)
            return;
        const next = controlCenterWidgets.slice();
        const moved = next.splice(from, 1)[0];
        next.splice(to, 0, moved);
        controlCenterWidgets = next;
        scheduleSave();
    }

    function moveControlCenterWidgetRelative(sourceId, targetId, after) {
        let from = -1;
        for (let i = 0; i < controlCenterWidgets.length; i++) {
            if (controlCenterWidgets[i].id === sourceId) {
                from = i;
                break;
            }
        }
        if (from < 0 || sourceId === targetId)
            return;

        const next = controlCenterWidgets.slice();
        const moved = next.splice(from, 1)[0];
        let targetIndex = -1;
        for (let i = 0; i < next.length; i++) {
            if (next[i].id === targetId) {
                targetIndex = i;
                break;
            }
        }
        if (targetIndex < 0)
            return;

        next.splice(after ? targetIndex + 1 : targetIndex, 0, moved);
        controlCenterWidgets = next;
        scheduleSave();
    }

    function resetPanel() {
        barVisible = true;
        barHeight = 34;
        barWidthPercent = 60;
        edgeGap = 24;
        screenMargin = 4;
        barPosition = "top";
        barWindowGap = 10;
        barAlignment = "center";
        barStyle = "classic";
        barControlCenterPosition = "right";
        barLayout = sanitizeBarLayout(defaultBarLayout);
        saveBarState();
    }

    function resetAppearance() {
        fontFamilyOverride = "";
        uiScale = 1.0;
        radiusScale = 1.0;
        shellOpacity = 0.94;
        animationsEnabled = true;
        animationScale = 1.0;
        externalThemeHook = "";
        scheduleSave();
    }

    function resetDateTime() {
        dateFormatOverride = "";
        timeFormatOverride = "";
        dateShow = true;
        clockShow = true;
        dateShowWeekday = true;
        dateShowYear = false;
        clockUse24Hour = false;
        clockShowSeconds = false;
        clockShowAmPm = true;
        dateTimeOrder = "date-first";
        scheduleSave();
    }

    function resetCalendar() {
        calendarFirstDay = 1;
        calendarShowWeekNumbers = true;
        calendarShowAdjacentMonths = true;
        calendarHighlightToday = true;
        calendarShowWeather = true;
        calendarWidth = 440;
        calendarCellHeight = 36;
        weatherLocation = "";
        scheduleSave();
    }

    function resetControlCenter() {
        controlCenterWidgets = sanitizeControlCenterWidgets(defaultControlCenterWidgets);
        controlCenterColumns = 2;
        controlCenterWidth = 440;
        controlCenterSpacing = 12;
        controlCenterShowMedia = true;
        controlCenterShowSliders = true;
        controlCenterShowThemeWallpaper = true;
        scheduleSave();
    }

    function resetWallpaper() {
        wallpaperDirectory = Quickshell.env("HOME") + "/Pictures/wallpapers";
        wallpaperScaling = "crop";
        wallpaperTransition = 300;
        scheduleSave();
    }

    function resetWindow() {
        settingsWidth = 1040;
        settingsHeight = 700;
        settingsSidebarPercent = 30;
        scheduleSave();
    }

    function resetAll() {
        resetPanel();
        resetAppearance();
        resetDateTime();
        resetCalendar();
        resetControlCenter();
        resetWallpaper();
        resetWindow();
        saveSettingsNow();
    }
}
