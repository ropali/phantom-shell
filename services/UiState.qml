pragma Singleton
import Quickshell

Singleton {
    property int openCount: 0
    readonly property bool anyOpen: openCount > 0

    signal dismissRequested()

    function popupOpened() {
        openCount++;
    }

    function popupClosed() {
        openCount = Math.max(0, openCount - 1);
    }

    function dismissAll() {
        dismissRequested();
    }
}
