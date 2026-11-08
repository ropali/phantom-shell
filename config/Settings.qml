pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: settings

    // Bar geometry and placement. Visual tokens live in themes/.
    property int barHeight: 34

    // Percentage of the monitor width occupied by the bar. 80 means the bar
    // spans 80% of the screen, leaving 10% free on each side.
    property int barWidthPercent: 60

    // Minimum gap between the bar and the left/right screen edges. The bar is
    // clamped so it never gets closer than this even with barWidthPercent 100.
    property int edgeGap: 24

    property int screenMargin: 4
    property string barPosition: "top"

    // Visible gap between the bar and tiled windows. Hyprland's gaps_out is
    // compensated automatically, so changing gaps_out does not change this
    // value. Set to 0 for windows to touch the bar.
    property int barWindowGap: 10

    // Workspaces
    property int workspaceMinCount: 0
    property int workspaceMaxCount: 10

    // Date and time
    property string dateFormat: "ddd, MMM dd"
    property string timeFormat: "hh:mm AP"

    // Temporary static wallpaper surface used while Noctalia is not running.
    // The full wallpaper module is scheduled for Milestone 6.
    property string wallpaperPath: Quickshell.env("HOME") + "/Pictures/wallpapers/Gruv/stairs.jpg"

    // Optional command run after a theme change, e.g. a script that updates
    // Hyprland borders, GTK, Qt or the icon theme. It is executed detached and
    // cannot break the Quickshell theme switch if it fails.
    property string externalThemeHook: ""

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

    readonly property string barStatePath: Quickshell.statePath("bar.json")

    FileView {
        id: barStateFile
        path: settings.barStatePath
        blockLoading: true
        watchChanges: false
        printErrors: false
    }

    Component.onCompleted: loadBarState()

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

    function loadBarState() {
        try {
            const text = barStateFile.text();
            if (!text || text.length === 0)
                return;
            const data = JSON.parse(text);

            if (data && Array.isArray(data.items)) {
                barLayout = sanitizeBarLayout(data.items);
                barControlCenterPosition = data.position === "left" ? "left" : "right";
                return;
            }

            // Migrate the previous per-button boolean format.
            if (data && typeof data === "object") {
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
        } catch (error) {
            console.warn("Failed to read bar settings:", error);
        }
    }

    function saveBarState() {
        try {
            barStateFile.setText(JSON.stringify({
                position: barControlCenterPosition,
                items: barLayout
            }));
        } catch (error) {
            console.warn("Failed to save bar settings:", error);
        }
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
}
