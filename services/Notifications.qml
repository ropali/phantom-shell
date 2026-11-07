pragma Singleton
import Quickshell

Singleton {
    // Milestone 2 exposes the shared notification state used by the bar.
    // The notification daemon, actions and grouping arrive in Milestone 4.
    property bool doNotDisturb: false
    property var history: []

    readonly property int count: history.length
    readonly property bool daemonAvailable: false

    function toggleDnd() {
        doNotDisturb = !doNotDisturb;
    }

    function clearAll() {
        history = [];
    }

    function dismiss(notification) {
        if (!notification)
            return;
        const index = history.indexOf(notification);
        if (index < 0)
            return;
        const next = history.slice();
        next.splice(index, 1);
        history = next;
    }
}
