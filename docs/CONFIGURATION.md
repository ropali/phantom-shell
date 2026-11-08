# Bar configuration

All bar geometry is configured in `config/Settings.qml`. Quickshell watches the
config and reloads QML changes, but compositor layout changes (width, height,
exclusive zone) can require a full restart to take effect cleanly:

```bash
pkill -x qs
qs -p $HOME/Workspace/phantom-shell --daemonize
```

After editing any geometry value, restart the shell once to be sure Hyprland
recalculates the reserved area.

## Width

```qml
property int barWidthPercent: 80
property int edgeGap: 24
```

- `barWidthPercent` is the percentage of the monitor width used by the bar.
  The bar stays centered, so the remaining percentage is split equally between
  the two sides.
- `edgeGap` is the minimum gap between the bar and the left/right screen edge.
  It clamps the computed width so the bar cannot touch the screen edge.

Examples:

| Goal | Setting |
|---|---|
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
property int barHeight: 34       // bar height in logical pixels
property int screenMargin: 4     // gap from the bar to the screen edge
property string barPosition: "top"  // "top" or "bottom"
```

## Bar styles

Two status bar layouts are available and can be switched live from the control
center's **Status bar** view:

- `classic` — the original single rounded bar with left, center and right
  sections.
- `pills` — floating glass pills: logo, workspace pager, pinned apps, centered
  clock, status pill, and separate control center and power buttons.

The setting is stored in `bar.json`:

```json
{ "style": "classic" }
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
pinned beside it. Open the control center, click the gear icon in its header,
and use the **Status bar** view to:

- Show or hide individual controls with the switches.
- Reorder them with the grip handles, or drag the icons directly on the status
  bar.
- Move the whole group to the left or right side of the bar with the
  **Control center position** selector (classic style only).
- Switch between **Classic** and **Pills** with the **Bar style** selector.

The layout is saved to `Quickshell.statePath("bar.json")` as:

```json
{
  "style": "classic",
  "position": "right",
  "items": [
    { "id": "notifications", "visible": true },
    { "id": "network", "visible": true },
    { "id": "bluetooth", "visible": true },
    { "id": "audio", "visible": true },
    { "id": "power", "visible": true }
  ]
}
```

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
