# Shared services

Phantom's UI must not talk to system APIs directly. Compositor, audio, network,
Bluetooth, notification, tray and session state live in `services/` singletons.
Modules and components read reactive properties and call service methods.

This is the shared-shell boundary used by the status bar and control center: if
a panel needs system state, add or extend a service instead of embedding
commands or `Quickshell.*` integrations in the panel.

## Service layer

| Service | Responsibility | Main API |
|---|---|---|
| `Hyprland.qml` | Workspace, monitor and compositor state | `workspaces`, `focusedWorkspace`, `workspaceIds()`, `workspaceById(id)`, `switchTo(id)`, `gapsOutTop/Bottom`, `refreshGaps()` |
| `Audio.qml` | PipeWire default devices, output/input volume and mute | `sink`, `source`, `sinks`, `sources`, `volume`, `volumePercent`, `sourceVolume`, `sourceVolumePercent`, `muted`, `sourceMuted`, `setVolume()`, `setSourceVolume()`, `adjustVolume()`, `toggleMute()`, `toggleSourceMute()`, `setDefaultSink()`, `setDefaultSource()` |
| `Network.qml` | Wi-Fi and wired network state | `wifiEnabled`, `wifiConnected`, `wiredConnected`, `connected`, `connectedWifiNetwork`, `networkList`, `wiredDevices`, `setScanning()`, `connectNetwork()`, `connectWithPassword()`, `disconnectNetwork()`, `toggleWifi()` |
| `Bluetooth.qml` | Adapter and device state | `available`, `enabled`, `connectedCount`, `deviceList`, `setDiscovering()`, `toggle()`, `toggleDevice()`, `deviceLabel()`, `deviceStateLabel()`, `isConnecting()` |
| `Notifications.qml` | Do Not Disturb and shared notification history | `doNotDisturb`, `history`, `count`, `daemonAvailable`, `toggleDnd()`, `clearAll()`, `dismiss()` |
| `Brightness.qml` | Display backlight percentage | `available`, `percent`, `refresh()`, `setPercent()` |
| `Battery.qml` | UPower display battery and AC state | `available`, `onBattery`, `percentage`, `state`, `stateLabel`, `charging`, `timeLabel` |
| `PowerProfiles.qml` | Power saver/balanced/performance profiles | `profile`, `hasPerformanceProfile`, `options`, `setProfile()` |
| `NightLight.qml` | Software warm overlay | `enabled`, `temperature`, `opacity`, `available`, `toggle()`, `setTemperature()` |
| `Wallpapers.qml` | Wallpaper discovery, selection and persistence | `directory`, `files`, `currentPath`, `refresh()`, `setWallpaper()`, `name()` |
| `Media.qml` | MPRIS now-playing state and controls | `player`, `available`, `playing`, `title`, `artist`, `album`, `artUrl`, `progress`, `togglePlaying()`, `next()`, `previous()` |
| `Weather.qml` | Current weather for the calendar flyout via wttr.in | `available`, `location`, `condition`, `temperature`, `humidity`, `icon`, `refresh()` |
| `SystemTray.qml` | StatusNotifierItem collection | `items`, `values`, `count` |
| `Session.qml` | Lock, logout, suspend, reboot and shutdown | `actions`, `run(action)`, `lock()`, `logout()`, `suspend()`, `reboot()`, `shutdown()` |
| `UiState.qml` | Popup coordination, detail keyboard state and outside-click dismissal | `openCount`, `anyOpen`, `detailOpen`, `popupOpened()`, `popupClosed()`, `dismissAll()`, `closeDetail()` |

## Reusable detail panels

`components/NetworkPanel.qml`, `BluetoothPanel.qml` and `AudioPanel.qml` contain
the actual management UI for their services. Both the status bar popups and the
control center detail views embed these panels, so the two entry points cannot
drift apart or duplicate system behavior. The control center overview itself is
`modules/controlcenter/ControlCenterOverview.qml`; it contains only compact
summary widgets and no full device, network, audio or wallpaper lists.

## Reactive state

Services expose plain QML properties or readonly bindings. UI bindings track
those properties, so changes in NetworkManager, BlueZ, PipeWire, Hyprland or the
tray propagate without polling. Services own any `Process`, `Timer` and
`Connections` objects needed to maintain that state.

## Integration exceptions

Some services need command-line fallbacks because the native APIs do not cover
the required data:

- `Hyprland.qml` reads `general:gaps_out` with `hyprctl getoption` to keep the
  bar/window gap correct.
- `Network.qml` reads wired interfaces with `nmcli` because this Quickshell
  build only enumerates Wi-Fi devices.
- `Session.qml` uses `loginctl`, `hyprctl` and `systemctl` because session
  actions are external commands.
- `Brightness.qml` uses `brightnessctl` because there is no backlight API in
  Quickshell.
- `Wallpapers.qml` uses `find` to enumerate the wallpaper library.

These are deliberate service-layer exceptions. Modules and components must not
add new ones.

Night light is implemented as a click-through warm overlay in
`modules/nightlight/NightLightOverlay.qml`, so it works without `hyprsunset` or a
gamma daemon. Wallpaper selection is persisted in
`Quickshell.statePath("wallpaper.json")`.

## Adding a service

1. Create a `pragma Singleton` QML file in `services/`.
2. Keep native Quickshell integrations, processes and timers inside the service.
3. Expose reactive properties and small intention-revealing methods.
4. Add the service and its API to this document.
5. Add a verification step to `docs/TESTING.md`.
