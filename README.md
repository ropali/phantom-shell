# Phantom

Phantom is a modular Quickshell desktop shell for CachyOS + Hyprland + Wayland,
intended to become a standalone project.

This repository implements **Milestone 0** (environment preparation),
**Milestone 1** (status bar), **Milestone 2** (shared shell services),
**Milestone 3** (control center) and **Milestone 4** (global settings
application), plus the mandatory **global theming system**.
It is intended to become a standalone project called Phantom; the extraction and
packaging plan is in [`docs/STANDALONE.md`](docs/STANDALONE.md).

## Requirements

- Quickshell (`qs`, provided by `noctalia-qs`; this is the Quickshell runtime, not the Noctalia shell)
- Hyprland running on Wayland
- Qt 6 with Qt Quick, Qt Quick Layouts and `Qt.labs.folderlistmodel`
- PipeWire (audio), NetworkManager (network), BlueZ (Bluetooth)

No additional packages were installed for this milestone. See
[`docs/PACKAGES.md`](docs/PACKAGES.md).

## Run

Development mode, without touching the session startup configuration:

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
│   ├── Brightness.qml
│   ├── Battery.qml
│   ├── PowerProfiles.qml
│   ├── NightLight.qml
│   ├── Wallpapers.qml
│   ├── Media.qml
│   ├── Weather.qml
│   ├── Session.qml
│   ├── SystemTray.qml
│   └── UiState.qml
├── modules/
│   ├── statusbar/            # bar, sections, calendar, tray, power menu
│   ├── controlcenter/        # dashboard and detail views
│   │   ├── ControlCenter.qml
│   │   ├── ControlCenterOverview.qml
│   │   ├── ControlCenterDetail.qml
│   │   ├── ControlCenterKeys.qml
│   │   ├── MediaCard.qml
│   │   └── views/            # Wi-Fi, Bluetooth, audio, theme, wallpaper details
│   ├── settings/             # global settings window, sidebar and pages
│   │   ├── SettingsWindow.qml
│   │   ├── SettingsSidebar.qml
│   │   ├── SettingsContent.qml
│   │   └── pages/            # panel, appearance, clock, calendar, etc.
│   ├── nightlight/           # click-through warm overlay
│   └── wallpaper/Wallpaper.qml   # wallpaper surface with scaling and fade
├── components/
│   ├── AudioPanel.qml        # shared with the bar audio popup
│   ├── BluetoothPanel.qml    # shared with the bar Bluetooth popup
│   ├── NetworkPanel.qml      # shared with the bar network popup
│   ├── IconButton.qml
│   ├── MiniSlider.qml
│   ├── OverviewSliderRow.qml
│   ├── Popup.qml
│   ├── QuickToggle.qml
│   ├── SettingRow.qml
│   ├── SettingSlider.qml
│   ├── Settings*.qml         # settings cards, rows, inputs and controls
│   ├── StatChip.qml
│   ├── ThemePicker.qml
│   ├── ToggleSwitch.qml
│   ├── Tooltip.qml
│   └── WallpaperPicker.qml
├── docs/
│   ├── CONFIGURATION.md
│   ├── PACKAGES.md
│   ├── SERVICES.md
│   ├── SESSION.md
│   ├── SETTINGS.md
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
- Left: date and time, with a native QML calendar flyout (live clock,
  week number, month grid and current weather).
- Center: Hyprland workspaces, driven by Quickshell's event-driven Hyprland
  integration. Click switches workspace; new workspaces appear automatically.
- Right: system tray with themed DBusMenu context menus, notification
  placeholder with Do Not Disturb, control center, network (Wi-Fi and
  Ethernet), Bluetooth, audio (output/input selection), and a power menu using
  real session APIs. Each control has its own popup; clicking another bar icon
  switches directly without a second click.

Two bar styles are available and can be switched live from the control
center's **Status bar** settings:

- `classic` — the single rounded bar described above.
- `pills` — floating glass pills for the logo, workspace pager, pinned apps,
  centered clock, status controls, and separate control center/power buttons.

The selection is persisted in Quickshell state. The classic layout is the
default; the pill layout uses the same services, control center and settings.

## Control center

The sliders button opens a compact vertical dashboard modeled on a desktop
quick-settings panel:

- Profile header with Phantom branding, power and close actions.
- A row of quick toggles for Wi-Fi, Bluetooth, DND and night light. Each tile
  toggles on click and opens its detail view from the small chevron.
- Output and input audio sliders with the active device names.
- Brightness and night-light sliders.
- A system card with battery/AC state and chips for network, Bluetooth and
  power profile.
- Side-by-side theme and wallpaper cards.
- A now-playing media card when an MPRIS player is available.

Clicking a card or chevron opens a dedicated detail view with a back action.
Wi-Fi, Bluetooth and audio reuse the same `NetworkPanel`, `BluetoothPanel` and
`AudioPanel` components as the status bar popups, so there is only one
implementation per system integration. The theme selector and wallpaper picker
also open as detail views. `Escape` closes the active detail view, and only one
detail view can be active at a time.

The dedicated network, Bluetooth, audio and power buttons remain in the bar.
Theme switching moved from the bar into the control center. Wallpaper selection
is persisted in Quickshell state.

Night light is a click-through warm overlay, so it works without a gamma daemon
or backlight control. Brightness is shown as unavailable on systems without a
`backlight` device. See [`docs/SERVICES.md`](docs/SERVICES.md).

## Global settings

The dedicated settings application is opened with `SUPER + ,`, from the gear
icon in the control center header, or with:

```bash
qs ipc -p $HOME/Workspace/phantom-shell call phantom settings
```

It is a centered, themed window with a searchable sidebar and pages for Panel,
Appearance, Date & Time, Calendar, Control Center, Launcher, Notifications,
Wallpaper, Keyboard Shortcuts and Advanced. Settings are applied immediately
and persisted in `bar.json` and `settings.json` under Quickshell's state path.
See [`docs/SETTINGS.md`](docs/SETTINGS.md) for the full reference.

## Bar configuration

Bar width is percentage-based (`barWidthPercent`), the gap between the bar and
tiled windows is configurable (`barWindowGap`), and Hyprland's `gaps_out` is
compensated automatically. See [`docs/CONFIGURATION.md`](docs/CONFIGURATION.md).

## Theming

All colors, typography, spacing, radii, padding, opacity and animation timings
come from the centralized theme system. Components contain no hardcoded theme
values.

Open the control center from the sliders icon in the bar, then choose a theme in
the Theme section. Themes apply live and the selection is persisted under
Quickshell's per-shell state directory.

Custom themes are JSON files dropped into `themes/custom/`. See
[`docs/THEMING.md`](docs/THEMING.md) for the schema and validation rules.

## Session integration

The shell is now the permanent session shell. `hyprland.lua` starts it at login:

```lua
hl.exec_cmd("qs -p $HOME/Workspace/phantom-shell --daemonize")
```

The Noctalia shell is no longer used and its user files have been removed. The
`noctalia-shell` package still needs to be uninstalled with
`sudo pacman -R noctalia-shell`. Keep `noctalia-qs`, which remains only as the
Quickshell runtime that provides `qs`. See [`docs/SESSION.md`](docs/SESSION.md)
for the removal details and backups.

This shell now owns the StatusNotifier watcher, so the system tray is populated.
A static wallpaper layer provides the desktop background. Wallpaper
selection is available in the control center and persists in Quickshell state.

## Hyprland keybindings

`SUPER + 1` through `SUPER + 9` already exist in
`hyprland/.config/hypr/keybindings.lua` and were left untouched, as required by
the migration rules. Hyprland creates a missing workspace when it is activated.
Workspace clicks use the Hyprland 0.57 Lua IPC dispatch syntax.

The Noctalia IPC binds were removed. `SUPER + SPACE` now launches
`hyprlauncher`; `SUPER + ,` opens the Phantom settings window through the
`phantom` IPC target; the direct `wpctl` and `brightnessctl` binds remain active,
as do the playerctl media keys.

## Known limitations

- The Noctalia shell is no longer used, so its launcher, control center,
  settings panel, OSD, notification daemon and annotation/lock IPC are gone.
  Use `hyprlauncher` (`SUPER + SPACE`) and the Phantom control center; Phantom's
  own launcher is scheduled for Milestone 5.
- There is currently no notification daemon. Applications that require
  `org.freedesktop.Notifications` will not show notifications until the
  notification milestone.
- The Launcher and Notifications settings categories are placeholders. Shortcut
  editing is read-only so Phantom never rewrites Hyprland bindings.
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
- The wallpaper is rendered by a dedicated background layer; the control center
  provides the selector and persists the chosen path.
- The installed `noctalia-qs` binary warns that it was built against Qt 6.11.2
  while the system provides Qt 6.12.0. It currently loads and runs, but the
  package should be rebuilt.
