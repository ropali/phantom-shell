pragma Singleton
import Quickshell

Singleton {
    // Session actions shared by the power menu and future control center.
    // UI components call these methods instead of invoking system commands.
    readonly property var actions: [
        { id: "lock", label: "Lock screen", icon: "\uf023", destructive: false },
        { id: "logout", label: "Logout", icon: "\uf2f5", destructive: false },
        { id: "suspend", label: "Suspend", icon: "\uf186", destructive: false },
        { id: "reboot", label: "Reboot", icon: "\uf021", destructive: true },
        { id: "shutdown", label: "Shutdown", icon: "\uf011", destructive: true }
    ]

    function run(action) {
        if (action === "lock")
            Quickshell.execDetached(["loginctl", "lock-session"]);
        else if (action === "logout")
            Quickshell.execDetached(["hyprctl", "dispatch", "exit"]);
        else if (action === "suspend")
            Quickshell.execDetached(["systemctl", "suspend"]);
        else if (action === "reboot")
            Quickshell.execDetached(["systemctl", "reboot"]);
        else if (action === "shutdown")
            Quickshell.execDetached(["systemctl", "poweroff"]);
    }

    function lock() {
        run("lock");
    }

    function logout() {
        run("logout");
    }

    function suspend() {
        run("suspend");
    }

    function reboot() {
        run("reboot");
    }

    function shutdown() {
        run("shutdown");
    }
}
