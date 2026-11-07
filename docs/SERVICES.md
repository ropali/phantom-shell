# Shared services

Phantom's UI must not talk to system APIs directly. Compositor, audio, network,
Bluetooth, notification, tray and session state live in `services/` singletons.
Modules and components read reactive properties and call service methods.

This is the Milestone 2 boundary: if a new panel needs system state, add or
extend a service instead of embedding commands or `Quickshell.*` integrations in
the panel.

## Service layer

| Service | Responsibility | Main API |
|---|---|---|
| `Hyprland.qml` | Workspace, monitor and compositor state | `workspaces`, `focusedWorkspace`, `workspaceIds()`, `workspaceById(id)`, `switchTo(id)`, `gapsOutTop/Bottom`, `refreshGaps()` |
| `Audio.qml` | PipeWire default devices, volume and mute | `sink`, `source`, `sinks`, `sources`, `volume`, `volumePercent`, `muted`, `setVolume()`, `adjustVolume()`, `toggleMute()`, `setDefaultSink()`, `setDefaultSource()` |
| `Network.qml` | Wi-Fi and wired network state | `wifiEnabled`, `wifiConnected`, `wiredConnected`, `connected`, `networkList`, `wiredDevices`, `setScanning()`, `connectNetwork()`, `connectWithPassword()`, `disconnectNetwork()`, `toggleWifi()` |
| `Bluetooth.qml` | Adapter and device state | `available`, `enabled`, `deviceList`, `setDiscovering()`, `toggle()`, `toggleDevice()`, `deviceLabel()`, `deviceStateLabel()`, `isConnecting()` |
| `Notifications.qml` | Do Not Disturb and shared notification history | `doNotDisturb`, `history`, `count`, `daemonAvailable`, `toggleDnd()`, `clearAll()`, `dismiss()` |
| `SystemTray.qml` | StatusNotifierItem collection | `items`, `values`, `count` |
| `Session.qml` | Lock, logout, suspend, reboot and shutdown | `actions`, `run(action)`, `lock()`, `logout()`, `suspend()`, `reboot()`, `shutdown()` |
| `UiState.qml` | Popup coordination and outside-click dismissal | `openCount`, `anyOpen`, `popupOpened()`, `popupClosed()`, `dismissAll()` |

## Reactive state

Services expose plain QML properties or readonly bindings. UI bindings track
those properties, so changes in NetworkManager, BlueZ, PipeWire, Hyprland or the
tray propagate without polling. Services own any `Process`, `Timer` and
`Connections` objects needed to maintain that state.

## Integration exceptions

Three services need command-line fallbacks because the native APIs do not cover
the required data:

- `Hyprland.qml` reads `general:gaps_out` with `hyprctl getoption` to keep the
  bar/window gap correct.
- `Network.qml` reads wired interfaces with `nmcli` because this Quickshell
  build only enumerates Wi-Fi devices.
- `Session.qml` uses `loginctl`, `hyprctl` and `systemctl` because session
  actions are external commands.

These are deliberate service-layer exceptions. Modules and components must not
add new ones.

## Adding a service

1. Create a `pragma Singleton` QML file in `services/`.
2. Keep native Quickshell integrations, processes and timers inside the service.
3. Expose reactive properties and small intention-revealing methods.
4. Add the service and its API to this document.
5. Add a verification step to `docs/TESTING.md`.
