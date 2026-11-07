pragma Singleton
import Quickshell
import QtQuick

Singleton {
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
    property int barWindowGap: 4

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
}
