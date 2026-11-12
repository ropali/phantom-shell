# Bar configuration

Bar defaults live in `config/Settings.qml`, but the recommended way to change
them is the global settings application: open it from the control center gear,
with `SUPER + ,`, or with `qs ipc -p $HOME/Workspace/phantom-shell call phantom
settings`, then use **Panel**.

Changes are applied live and persisted in `bar.json` under Quickshell's state
path. Quickshell watches QML edits, but if you change defaults directly in QML a
restart is still the safest way to make Hyprland recalculate the reserved area:

```bash
pkill -x qs
qs -p $HOME/Workspace/phantom-shell --daemonize
```

See [`SETTINGS.md`](SETTINGS.md) for the settings window, all categories and the
state-file schema.

## Width

```qml
property int barWidthPercent: 60
property int edgeGap: 24
property string barAlignment: "center"
```

- `barWidthPercent` is the percentage of the monitor width used by the bar.
- `barAlignment` is `left`, `center` or `right`. It applies to the classic bar;
  the pills layout always spans the screen.
- `edgeGap` is the minimum gap between the bar and the left/right screen edge.
  It clamps the computed width so the bar cannot touch the screen edge.

Examples:

| Goal | Setting |
|---|---|
| Bar spans 60% | `barWidthPercent: 60` |
| Bar spans 80%, 10% free on each side | `barWidthPercent: 80` |
| Bar spans 100%, but keeps a 24px edge gap | `barWidthPercent: 100` (the `edgeGap` clamp applies) |
| Bar spans 50% | `barWidthPercent: 50` |

## Gap between the bar and tiled windows

```qml
property int barWindowGap: 4
```

`barWindowGap` is the visible gap between the bottom of the bar and the top of a
tiled window (or the top of the bar and the bottom of a window when the bar is at
the bottom). Set it to `0` for windows to touch the bar.

Hyprland normally adds its own `general:gaps_out` between the reserved bar space
and window edges. The shell reads `general:gaps_out` from Hyprland and subtracts
it from the reserved zone, so `barWindowGap` is the real visible gap and stays
correct when `gaps_out` changes. The value is re-read when Hyprland reloads its
configuration.

Do not confuse this with `screenMargin`, which is the gap between the bar and the
screen edge.

## Other bar options

```qml
property bool barVisible: true
property int barHeight: 34       // bar height in logical pixels
property int screenMargin: 4     // gap from the bar to the screen edge
property string barPosition: "top"  // "top" or "bottom"
property string barAlignment: "center" // "left", "center" or "right"
```

These values, plus the module list, are saved to `bar.json`. Older bar files
that only contain `style`, `position` and `items` continue to load with the
defaults above.

## Bar styles

Two status bar layouts are available and can be switched live from the
settings application under **Panel → General**:

- `classic` — the original single rounded bar with left, center and right
  sections.
- `pills` — floating glass pills: logo, workspace pager, pinned apps, centered
  clock, status pill, and separate control center and power buttons.

The setting is stored in `bar.json` together with the other bar options:

```json
{
  "style": "classic",
  "visible": true,
  "height": 34,
  "widthPercent": 60,
  "edgeGap": 24,
  "screenMargin": 4,
  "barWindowGap": 10,
  "barPosition": "top",
  "alignment": "center",
  "items": []
}
```

`barWidthPercent`, `edgeGap` and the **Control center position** selector apply
to the classic style. The pill style spans the screen with fixed outer margins.

### Pinned apps (pill style)

The pills layout shows a configurable app launcher pill. Edit
`config/Settings.qml`:

```qml
property var pinnedApps: [
    { icon: "\uf120", label: "Terminal", command: "ghostty", color: "info" },
    { icon: "\uf269", label: "Browser", command: "google-chrome-stable", color: "warning" },
    { icon: "\uf07b", label: "Files", command: "dolphin", color: "secondary" },
    { icon: "\uf1bc", label: "Spotify", command: "spotify", color: "success" },
    { icon: "\uf392", label: "Discord", command: "discord", color: "tertiary" }
]
```

`icon` is a Nerd Font glyph, `command` is run through `sh -c`, and `color`
selects a theme role (`info`, `warning`, `success`, `secondary`, `tertiary`).

## Calendar weather

The calendar flyout shows current weather from [wttr.in](https://wttr.in). By
default the location is detected from the public IP. Override it in
`config/Settings.qml`:

```qml
property string weatherLocation: "Budapest"
```

Leave it empty for automatic detection. Weather is fetched every 30 minutes and
when the calendar opens; if the request fails, the weather card is hidden. This
uses `curl` and network access.

## Status bar buttons

In the classic style, the Network, Bluetooth, Volume, Notifications and Power
controls, the system tray and the control center button form a single **control
center group**. In the pills style the configurable controls live in the status
pill, Power becomes a separate round button, and the control center button stays
pinned beside it.

Open the settings application and use **Panel → Modules** to:

- Show or hide individual controls with the switches.
- Reorder them with the arrow buttons, or drag the icons directly on the status
  bar.
- Move the whole group to the left or right side of the bar with the
  **Control center group** selector (classic style only).
- Switch between **Classic** and **Pills** under **Panel → General**.

Module order and visibility are saved in the `items` array in `bar.json`.
Dragging icons on the bar and reordering in settings operate on the same list.

Settings saved by older versions (one boolean per button, or the previous
per-icon `side` format) are migrated automatically.

The date/time and workspace modules remain independent, fixed modules for now.
Moving those modules is planned for a later iteration, so the group position
only relocates the control center group; the other modules flow around it.

## Complete example

```qml
// config/Settings.qml
property int barHeight: 34
property int barWidthPercent: 80
property int edgeGap: 24
property int screenMargin: 4
property string barPosition: "top"
property int barWindowGap: 4
```

With a 2560px-wide monitor this produces a 2048px bar centered at x=256, leaving
256px (10%) free on each side, and a 4px visible gap between the bar and tiled
windows.


## Other settings files

The settings application writes `settings.json` for everything that is not bar
geometry or wallpaper selection:

```text
settings.json
├── date/time formats and visibility
├── calendar week/content/size options
├── appearance overrides (font, scale, radius, opacity, animations)
├── wallpaper directory, scaling and fade duration
├── control center columns, width, spacing, cards and sections
└── settings window size and sidebar width
```

The active theme stays in `theme.json` and the current wallpaper path stays in
`wallpaper.json`. All three files live in the same Quickshell state directory
and are shown in **Advanced → Diagnostics**. Missing or invalid values fall back
to `config/Settings.qml` defaults, and numeric values are clamped.

## Date, calendar and control center

- **Date & Time** controls the bar clock: 12/24-hour format, seconds, AM/PM,
  optional custom Qt format strings, date fields and date/time ordering. The
  page includes a live preview. Custom display formats never change the system
  timezone.
- **Calendar** controls the first weekday, week numbers, adjacent-month dates,
  today highlighting, weather visibility, popup width and cell height.
- **Control Center** controls quick-card order and visibility, 2/3 columns,
  popup width, card spacing and whether the media, slider and theme/wallpaper
  sections are shown. If you choose three columns, increase the panel width.

## Appearance and wallpaper

- **Appearance** applies a theme, an optional font family override, text scale,
  corner radius scale, surface opacity, animation toggle/speed and an optional
  post-theme command. These override the active theme through `Theme.qml`.
- **Wallpaper** lists the configured directory, lets you pick a file through the
  shared wallpaper selector, sets crop/fit/stretch/center scaling, controls the
  fade duration and can shuffle the current library.
