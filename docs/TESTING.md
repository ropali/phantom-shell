# Testing and validation

This document records how the shell was validated. Results distinguish between
what was syntactically validated, runtime tested, system-integration tested, and
what still requires user acceptance testing.

## Static validation

Performed:

```bash
# Configuration load (fails on syntax/type errors)
qs -p $HOME/Workspace/phantom-shell

# JSON validity of every theme
for f in themes/palettes/*.json themes/presets/*.json; do
  python3 -m json.tool "$f" > /dev/null
done

# No component-level hardcoded theme values
grep -rnE '"#[0-9a-fA-F]{6,8}"' --include='*.qml' components modules
```

Results:

- Configuration loads with `Configuration Loaded` and no QML type, property or
  binding errors.
- All bundled palettes and the preset are valid JSON.
- No hex colors remain in `components/` or `modules/`.
- `Config.Theme` no longer exists; all visual values resolve through
  `themes/Theme.qml`.

## Runtime validation

Command:

```bash
qs -p $HOME/Workspace/phantom-shell
```

Observed:

- `Configuration Loaded` with no QML errors.
- Layer surface exists on the monitor:
  `namespace: phantom-bar`, full-width surface, bar height 34 + 4 margin.
- Bar renders on the monitor (screenshot taken with `grim`).
- Popup components were additionally rendered in a copied config with
  `shown: true` to validate their layout: calendar, network, Bluetooth, audio, theme switcher and power menu
  and theme switcher all rendered.
- Quickshell services reported live state after the shell loaded:
  audio sink present, Wi-Fi/network connected, 5 Bluetooth devices, 1 tray item,
  workspaces `1,2`, focused workspace `2`.

Notes:

- Quickshell's service singletons in this build initialise a few seconds after
  startup, and appear to need to be referenced from live bindings (as the bar
  does). A standalone test config that only touched services from a timer
  observed unavailable backends; the real shell did not.
- All popups with `grabFocus: true` require the parent layer surface to have
  received input before Wayland will create a grabbing popup. This is expected;
  normal click-driven use satisfies it.

## Functional checks

| Test | Result | Level |
|---|---|---|
| Start shell | Bar appears on both the primary and only monitor | Runtime tested |
| Date/time | Correct date and time render, updates every minute | Runtime tested |
| Click date/time | Opens calendar popup | Popup rendered; click path not automated |
| Navigate calendar | Previous/next month and Today handlers present | Not automated |
| Workspace indicator | Shows existing workspaces, active workspace highlighted | Runtime tested |
| Click workspace | Calls Hyprland IPC with Lua dispatch | System integration tested via `hyprctl dispatch 'hl.dsp.focus({ workspace = 1 })'` |
| Open network popup | Opens only the network popup, only its icon is highlighted | Click-injected and screenshot-verified |
| Network popup | Lists Wi-Fi networks and the Ethernet interface | Verified: `enp130s0` connected |
| Wi-Fi scanning | Popup starts a scan and fills the list with nearby networks | Verified: 12 networks after the scan completed |
| Wi-Fi password | Clicking an unknown WPA network opens a screen-centered password dialog | Verified, including keyboard input in the focused password field |
| Password reveal | Eye button toggles between hidden and visible password | Verified: masked dots toggled to plaintext and back |
| Network row styling | Ethernet row uses a transparent background like Wi-Fi rows | Verified |
| Wi-Fi connect | Connect is sent through `connectWithPsk` for new PSK networks | Password entry verified; not executed with a real password |
| Wi-Fi failure feedback | A failed connection attempt reports an error after the timeout | Shared code path with the verified Bluetooth timeout feedback |
| Bluetooth discovery | Popup enables discovery and lists newly found devices | Verified: `FireBoltt 125` appeared as a new "Pair" entry |
| Bluetooth connect | Paired devices show Connect; connected devices show Disconnect | UI verified |
| Bluetooth failure feedback | Trying a powered-off/out-of-range device reports an error after the timeout | Verified: "Could not connect to Nirvana Zenith Pro. Make sure it is on and in range." |
| Open Bluetooth popup | Opens only the Bluetooth popup | Popup rendering verified |
| Open audio popup | Opens only the audio popup | Click-injected and screenshot-verified |
| Audio popup | Shows output volume, output device selection, input device selection | Verified: 15% volume, HDMI output selected, input section present |
| Switch popups | Clicking another bar icon switches popups in one click | Click-injected and screenshot-verified |
| Click inside popup | Popup stays open and receives the click | Verified via the volume slider |
| Click outside popup | Popup closes | Click-injected and screenshot-verified |
| SUPER + 3 / SUPER + 9 | Existing Hyprland keybindings, unchanged | Configuration inspected |
| Switch workspace externally | Bar workspace list/active state updates via Quickshell event integration | Runtime tested |
| Bluetooth indicator | Reflects adapter state and devices | Runtime tested (service data) |
| Audio indicator | Reflects sink volume and mute state | Runtime tested (service data) |
| Tray applet | Tray service returns items | Verified: 1 Steam item |
| Tray applet menu | Right-clicking a tray icon opens its DBusMenu; entries trigger actions and submenus navigate in-place | Menu rendered and verified with the Steam applet; right-click path shares the working popup code |
| Power menu | Opens; actions call `loginctl`, `hyprctl`, `systemctl` | Popup rendered; actions not executed |
| Multiple monitors | One `StatusBar` instance per `Quickshell.screens` entry | Code path implemented; only one monitor available |
| Bar width percentage | `barWidthPercent: 80` produces a 2048px bar on a 2560px monitor, centered at x=256 | Verified from runtime geometry |
| Bar/window gap | `barWindowGap: 4` leaves a 4px visible gap below the bar; Hyprland `gaps_out` is compensated | Verified with tiled window at y=42 and bar bottom at 38 |

## Theming validation

Run in a copy of the project to avoid disturbing the live session:

| Test | Result |
|---|---|
| Load all bundled themes | 6 themes discovered: catppuccin-mocha, dracula, gruvbox, nord, rose-pine, tokyo-night |
| Switch theme live | `applyTheme("tokyo-night")` changed `Theme.background` from `#282828` to `#1a1b26` and `Theme.primary` from `#b8bb26` to `#7aa2f7` without restart |
| All existing modules update | Bar, workspace indicator, popup surfaces and theme switcher re-rendered with the Tokyo Night palette |
| Persistence across restart | State file contained `{"theme":"tokyo-night"}`; a fresh process restored Tokyo Night before any switch |
| Invalid theme | A malformed JSON file was rejected with a logged reason; the previous valid theme stayed active |
| Custom theme discovery | Dropping `themes/custom/my-custom.json` produced 7 themes with no QML changes |
| Theme switcher UI | Renders names, five-color previews, active highlight and custom-theme hint |
| Duplicate windows / state reset | No duplicated bar or popups observed during live switching |

Theme persistence location:

```text
Quickshell.statePath("theme.json")
# e.g. $HOME/.local/state/noctalia-qs/by-shell/<shell-id>/theme.json
```

## Session integration validation

Performed in the live Hyprland session:

```bash
pkill -x qs
pkill -x noctalia
qs -p $HOME/Workspace/phantom-shell --daemonize
hyprctl layers
busctl --user list | grep -iE "StatusNotifier|notifications"
```

Results:

| Check | Result |
|---|---|
| Noctalia stopped | No `noctalia` process or layer surfaces remain |
| Phantom running | One instance (PID 91159 at test time), config `$HOME/Workspace/phantom-shell` |
| Bar layer | `phantom-bar`, `0 4 2560 38` |
| Wallpaper layer | `phantom-wallpaper`, `0 0 2560 1440` |
| Tray watcher | `org.kde.StatusNotifierWatcher` and `StatusNotifierHost` owned by `qs` |
| Tray icons | Populate after Noctalia releases the watcher |
| Notification daemon | No owner for `org.freedesktop.Notifications` (expected until Milestone 4) |
| Duplicate instances | None |

Startup at login was not tested without a reboot. The configured command is the
exact command verified manually, and both edited Lua files pass `luac -p`.

## Known issues and limitations

- `noctalia-qs` warns that it was built against Qt 6.11.2 while Qt 6.12.0 is
  installed. It runs, but the package should be rebuilt.
- The session now runs only Phantom, so it owns the StatusNotifier
  watcher and tray icons populate. If Noctalia is started manually for fallback,
  it takes the watcher back and the custom tray will be empty.
- There is no notification daemon until Milestone 4. Applications cannot show
  desktop notifications in the meantime.
- Noctalia's launcher, control center, settings panel, OSD and annotation/lock
  IPC are inactive. Their existing keybindings only work in the manual Noctalia
  fallback session.
- The desktop wallpaper is a temporary static Quickshell background layer with
  `Settings.wallpaperPath`; the wallpaper selector arrives in Milestone 6.
- `loginctl lock-session` emits a standard lock request but no locker is
  installed on this system.
- Clicking, scrolling and keyboard acceptance were not automated on Wayland.
  These require the user's final behavioral testing.

## User acceptance checklist

1. Click the date/time; confirm the calendar opens and closes on outside click.
2. Navigate months and use Today.
3. Click each workspace and confirm the active workspace changes.
4. Press `SUPER + 3` and `SUPER + 9`; confirm a missing workspace is created.
5. Click network, Bluetooth and audio icons; exercise toggles and device rows.
6. Right-click a tray applet and exercise its context menu.
7. Open the power menu; verify each action on a safe session.
8. Open the theme switcher; switch themes; restart Quickshell and confirm the
   choice persists.
