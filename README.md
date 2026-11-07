# Phantom

Phantom is a modular Quickshell desktop shell for CachyOS + Hyprland + Wayland,
built as an incremental replacement for Noctalia and intended to become a standalone project.

This repository implements **Milestone 0** (environment preparation),
**Milestone 1** (status bar) and **Milestone 2** (shared shell services), plus
the mandatory **global theming system**. It is intended to become a standalone
project called Phantom; the extraction and packaging plan is in
[`docs/STANDALONE.md`](docs/STANDALONE.md).

## Requirements

- Quickshell (`qs`, provided here by `noctalia-qs`)
- Hyprland running on Wayland
- Qt 6 with Qt Quick, Qt Quick Layouts and `Qt.labs.folderlistmodel`
- PipeWire (audio), NetworkManager (network), BlueZ (Bluetooth)

No additional packages were installed for this milestone. See
[`docs/PACKAGES.md`](docs/PACKAGES.md).

## Run

Development mode, without touching the Noctalia startup configuration:

```bash
qs -p /path/to/quickshell
```

The shell writes logs to the Quickshell log location reported on startup. Use

```bash
qs log
```

to inspect the most recent run.

## Project layout

```text
phantom-shell/
├── shell.qml
├── config/
│   └── Settings.qml          # layout preferences, not visual tokens
├── themes/
│   ├── ThemeManager.qml      # loading, switching, validation, persistence
│   ├── Theme.qml             # token facade used by every component
│   ├── ThemeLoader.qml       # per-file JSON loader and validator
│   ├── palettes/             # bundled themes
│   ├── custom/               # user themes (*.json)
│   └── presets/default.json  # default theme id
├── services/
│   ├── Hyprland.qml
│   ├── Audio.qml
│   ├── Network.qml
│   ├── Bluetooth.qml
│   ├── Notifications.qml
│   ├── Session.qml
│   ├── SystemTray.qml
│   └── UiState.qml
├── modules/
│   ├── statusbar/            # bar, sections, calendar, tray, power menu
│   ├── theme/ThemeSwitcher.qml
│   └── wallpaper/Wallpaper.qml   # temporary static wallpaper surface
├── components/
│   ├── IconButton.qml
│   ├── Popup.qml
│   ├── ToggleSwitch.qml
│   └── Tooltip.qml
├── docs/
│   ├── CONFIGURATION.md
│   ├── PACKAGES.md
│   ├── SERVICES.md
│   ├── SESSION.md
│   ├── STANDALONE.md
│   ├── TESTING.md
│   └── THEMING.md
└── assets/
```

## Shared services

All system integrations live in [`services/`](services/) and are documented in
[`docs/SERVICES.md`](docs/SERVICES.md). Panels read reactive service properties
and call service methods; they do not run `hyprctl`, `nmcli`, `wpctl`,
`systemctl` or other integration commands themselves.

## Status bar

- Floating, rounded, centered bar with configurable top/bottom placement,
  height, percentage width and edge gap (`config/Settings.qml`).
- Layer-shell surface, `phantom-bar` namespace, input region limited to the
  bar so the transparent strip does not eat clicks.
- One bar instance per monitor.
- Left: date and time, with a native QML calendar popup.
- Center: Hyprland workspaces, driven by Quickshell's event-driven Hyprland
  integration. Click switches workspace; new workspaces appear automatically.
- Right: system tray with themed DBusMenu context menus, notification
  placeholder with Do Not Disturb, theme switcher, network (Wi-Fi and
  Ethernet), Bluetooth, audio (output/input selection), and a power menu using
  real session APIs. Each control has its own
  popup; clicking another bar icon switches directly without a second click.

## Bar configuration

Bar width is percentage-based (`barWidthPercent`), the gap between the bar and
tiled windows is configurable (`barWindowGap`), and Hyprland's `gaps_out` is
compensated automatically. See [`docs/CONFIGURATION.md`](docs/CONFIGURATION.md).

## Theming

All colors, typography, spacing, radii, padding, opacity and animation timings
come from the centralized theme system. Components contain no hardcoded theme
values.

Open the theme switcher from the palette icon in the bar. Themes apply live and
the selection is persisted under Quickshell's per-shell state directory.

Custom themes are JSON files dropped into `themes/custom/`. See
[`docs/THEMING.md`](docs/THEMING.md) for the schema and validation rules.

## Session integration

The shell is now the permanent session shell. `hyprland.lua` starts it at login:

```lua
hl.exec_cmd("qs -p $HOME/Workspace/phantom-shell --daemonize")
```

and the Noctalia autostart line was removed. Noctalia is still installed and can
be launched manually as a fallback. See [`docs/SESSION.md`](docs/SESSION.md) for
the exact changes and rollback commands.

This shell now owns the StatusNotifier watcher, so the system tray is populated.
A temporary static wallpaper layer replaces Noctalia's wallpaper surface until
the wallpaper module is implemented in Milestone 6.

## Hyprland keybindings

`SUPER + 1` through `SUPER + 9` already exist in
`hyprland/.config/hypr/keybindings.lua` and were left untouched, as required by
the migration rules. Hyprland creates a missing workspace when it is activated.
Workspace clicks use the Hyprland 0.57 Lua IPC dispatch syntax.

The Noctalia IPC volume/brightness binds were disabled because they would call a
process that is no longer running. The direct `wpctl` and `brightnessctl` binds
remain active, as do the playerctl media keys.

## Known limitations

- Noctalia's launcher, control center, settings panel, OSD, notification daemon
  and annotation/lock IPC are unavailable while it is not running. Their
  keybindings still exist for the manual Noctalia fallback.
- There is currently no notification daemon. Applications that require
  `org.freedesktop.Notifications` will not show notifications until Milestone 4.
- Wi-Fi scanning starts when the network popup opens and may take several seconds
  to populate. The list is disabled again when the popup closes.
- Connecting to a new WPA/WPA2/SAE network opens a password prompt. Enterprise
  (EAP) networks are not supported by the password prompt; already-saved
  enterprise profiles connect through NetworkManager.
- Bluetooth discovery starts when the Bluetooth popup opens. Connecting to a
  paired device works; pairing a brand-new device depends on a BlueZ pairing
  agent and may not complete if none is running.
- Ethernet status is read with `nmcli` because Quickshell's Networking module
  only enumerates Wi-Fi devices in this build.
- The lock action uses `loginctl lock-session`. A session locker must be
  installed/configured separately (not part of this milestone).
- The wallpaper is a temporary static image surface, not the Milestone 6
  wallpaper selector.
- The installed `noctalia-qs` binary warns that it was built against Qt 6.11.2
  while the system provides Qt 6.12.0. It currently loads and runs, but the
  package should be rebuilt.
