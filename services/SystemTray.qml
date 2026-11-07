pragma Singleton
import Quickshell
import Quickshell.Services.SystemTray as Tray

Singleton {
    readonly property var items: Tray.SystemTray.items
    readonly property var values: items ? items.values : []
    readonly property int count: values.length
}
