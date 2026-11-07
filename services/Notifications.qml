pragma Singleton
import Quickshell

Singleton {
    // Milestone 1 only tracks the local Do Not Disturb preference.
    // The notification daemon and history arrive in Milestone 4.
    property bool doNotDisturb: false
    property int count: 0

    function toggleDnd() {
        doNotDisturb = !doNotDisturb;
    }
}
