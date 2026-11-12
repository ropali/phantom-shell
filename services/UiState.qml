pragma Singleton
import Quickshell

Singleton {
    property int openCount: 0
    property bool detailOpen: false
    property bool settingsOpen: false
    readonly property bool anyOpen: openCount > 0

    signal dismissRequested()
    signal detailCloseRequested()

    function popupOpened() {
        openCount++;
    }

    function popupClosed() {
        openCount = Math.max(0, openCount - 1);
    }

    function dismissAll() {
        dismissRequested();
    }

    function closeDetail() {
        detailCloseRequested();
    }

    function openSettings() {
        dismissRequested();
        settingsOpen = true;
    }

    function closeSettings() {
        settingsOpen = false;
    }

    function toggleSettings() {
        if (settingsOpen)
            closeSettings();
        else
            openSettings();
    }
}
