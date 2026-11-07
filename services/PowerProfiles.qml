pragma Singleton
import Quickshell
import Quickshell.Services.UPower

Singleton {
    id: service

    readonly property int profile: PowerProfiles.profile
    readonly property bool hasPerformanceProfile: PowerProfiles.hasPerformanceProfile
    readonly property var options: [
        { id: PowerProfile.PowerSaver, label: "Power saver", icon: "\uf0e7" },
        { id: PowerProfile.Balanced, label: "Balanced", icon: "\uf24e" },
        { id: PowerProfile.Performance, label: "Performance", icon: "\uf135" }
    ]

    function setProfile(value) {
        PowerProfiles.profile = value;
    }

    function profileLabel(value) {
        return PowerProfile.toString(value);
    }
}
