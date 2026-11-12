# Global settings

Phantom has a dedicated settings application, separate from the control
center. The control center is for quick actions and the settings application is
for persistent shell configuration.

## Opening the settings window

- Press `SUPER + ,` (Hyprland binding in `keybindings.lua`).
- Click the gear icon in the control center header.
- Run the IPC command manually:

```bash
qs ipc -p $HOME/Workspace/phantom-shell call phantom settings
```

`toggleSettings` is also available:

```bash
qs ipc -p $HOME/Workspace/phantom-shell call phantom toggleSettings
```

All entry points open the single `SettingsWindow` instance. The window is a
full-screen layer surface with a centered card, so outside clicks close it and
`Escape` also closes it. It opens on the monitor containing the focused
Hyprland workspace and stays within the available screen area.

## Layout

The window uses a two-column layout:

- Left sidebar: category search and navigation, 30% by default.
- Right content area: a scrollable category page with grouped cards.

The sidebar width, window width and window height are configurable in
**Advanced → Settings window**.

## Categories

| Category | Contents |
|---|---|
| Panel | Bar visibility, style, position, alignment, dimensions and module visibility/order |
| Appearance | Theme selection, external theme hook, font family, text scale, corner radius, opacity and animations |
| Date & Time | Clock/date visibility, 12/24-hour time, seconds, AM/PM, custom formats, ordering and live preview |
| Calendar | First weekday, week numbers, adjacent-month dates, today highlight, weather, width and cell height |
| Control Center | Quick card visibility and order, columns, width, spacing and section visibility |
| Launcher | Placeholder until the launcher milestone |
| Notifications | Placeholder until the notification milestone |
| Wallpaper | Current preview, picker, directory, scaling, fade duration and shuffle |
| Keyboard Shortcuts | Registered Phantom shortcuts and the Hyprland keybindings file |
| Advanced | Settings window size, versions/paths, per-category resets and reset-all |

The theme selector is the shared `ThemePicker` component and the wallpaper
picker is the shared `WallpaperPicker` component. Both use the same
`ThemeManager` and `Wallpapers` services as the control center; there is no
second theme or wallpaper implementation.

## Persistence

Settings are stored in the Quickshell state directory for this shell instance:

| File | Contents |
|---|---|
| `bar.json` | Bar style, control center position, visibility, height, width percent, edge gap, screen margin, window gap, position, alignment and module order |
| `settings.json` | Date/time, calendar, appearance overrides, wallpaper options, control center options and settings window dimensions |
| `theme.json` | Active theme id (managed by `ThemeManager`) |
| `wallpaper.json` | Current wallpaper path (managed by `Wallpapers`) |

`bar.json` keeps its existing `style`, `position` and `items` fields, so older
bar layouts continue to load. Missing fields fall back to the defaults in
`config/Settings.qml`; numeric values are clamped when loaded. Slider changes
are debounced before writing, and `settings.json` is also flushed when the
settings window closes or the shell exits.

The config directory is available in **Advanced**, along with the exact state
paths for the current instance.

## Theme integration

Every settings component uses `themes/Theme.qml` tokens. The appearance overrides
are applied through `Theme`:

- Text scale scales every font size token.
- Corner radius scales the theme radius tokens.
- Surface opacity replaces `Theme.opacity`.
- Animation scale and the animations switch change the theme durations.

Changing the active theme updates the settings window immediately. Custom themes
in `themes/custom/*.json` appear in the selector without changing settings QML.

## Resets

The Advanced page can reset each category or every Phantom setting. Reset-all
also applies the default theme. Destructive resets ask for confirmation in the
window before running.

## Deferred pieces

- Launcher and notification settings appear as placeholders until their
  milestones are implemented.
- Shortcut editing is read-only because Phantom does not rewrite Hyprland
  keybindings automatically. The page shows the file to edit and can open it.
- Wallpaper transitions are cross-fades of the single background layer; there
  is no per-monitor wallpaper selection yet.
- Configuration import/export is not implemented; the state files above can be
  backed up directly.
