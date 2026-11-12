# Global theming system

The shell uses one centralized theming system. UI components never define
colors, fonts, spacing, radii, padding, opacity or animation durations
themselves; they read tokens from `themes/Theme.qml`.

## Files

| File | Responsibility |
|---|---|
| `themes/ThemeManager.qml` | Discovers theme files, loads and registers them, tracks the active theme, validates, persists, exposes `applyTheme()` |
| `themes/ThemeLoader.qml` | Loads one JSON file and validates it against the schema |
| `themes/Theme.qml` | Token facade consumed by every component |
| `themes/palettes/*.json` | Bundled themes |
| `themes/custom/*.json` | User-installed themes |
| `themes/presets/default.json` | Default theme id (`defaultTheme`) |
| `config/Settings.qml` | Non-visual layout preferences (bar height, placement, date/time formats, workspace range) |

`ThemeManager` is the only component that applies a palette. Adding a theme never
requires editing a UI component.

## Bundled themes

- `gruvbox.json` — Gruvbox Dark (default)
- `catppuccin-mocha.json`
- `tokyo-night.json`
- `nord.json`
- `dracula.json`
- `rose-pine.json`

## Theme schema

Every theme must provide all of the following fields. Files missing a required
field, containing invalid colors or invalid numbers are rejected and the
previous valid theme stays active.

```json
{
  "id": "my-theme",
  "name": "My Theme",
  "colors": {
    "background": "#1e1e2e",
    "surface": "#313244",
    "surfaceElevated": "#45475a",
    "primary": "#cba6f7",
    "secondary": "#89b4fa",
    "tertiary": "#94e2d5",
    "foreground": "#cdd6f4",
    "mutedForeground": "#a6adc8",
    "disabled": "#585b70",
    "border": "#45475a",
    "success": "#a6e3a1",
    "warning": "#f9e2af",
    "error": "#f38ba8",
    "info": "#89dceb",
    "onPrimary": "#1e1e2e",
    "onSecondary": "#1e1e2e",
    "onTertiary": "#1e1e2e"
  },
  "typography": {
    "fontFamily": "JetBrainsMono Nerd Font",
    "iconFontFamily": "JetBrainsMono Nerd Font",
    "sizeTiny": 9,
    "sizeSmall": 10,
    "sizeBase": 11,
    "sizeMedium": 12,
    "size": 13,
    "sizeLarge": 16,
    "sizeXLarge": 20,
    "weightNormal": 400,
    "weightMedium": 500,
    "weightBold": 700,
    "lineHeight": 1.3
  },
  "spacing": { "xs": 2, "sm": 4, "md": 8, "lg": 12, "xl": 16 },
  "components": {
    "radius": 12,
    "radiusSmall": 7,
    "radiusLarge": 18,
    "borderWidth": 1,
    "padding": 12,
    "opacity": 0.94,
    "buttonSize": 26,
    "iconSize": 15,
    "trayIconSize": 16,
    "workspaceButtonSize": 24,
    "controlHeight": 34,
    "rowHeight": 30,
    "shadow": true
  },
  "animation": {
    "fast": 120,
    "normal": 200,
    "slow": 300,
    "easing": "OutCubic"
  }
}
```

Rules enforced by `ThemeLoader.qml`:

- `id` must match `^[a-z0-9-]+$`.
- Every color must be `#RRGGBB` or `#RRGGBBAA`.
- Every size, weight, spacing, radius, duration and opacity must be a finite
  number.
- `components.shadow` must be a boolean.
- Unknown extra fields are ignored.

## Installing a custom theme

1. Copy a bundled palette as a starting point.
2. Give the file a unique `id`.
3. Save it as `themes/custom/<name>.json`.
4. Open the control center (sliders icon in the bar), find the Theme section and
   select it. No QML changes and no restart are required.

## Switching and persistence

- The control center lists every valid theme, shows color previews and
  highlights the active one.
- Selecting a theme calls `ThemeManager.applyTheme(id)`. All bound components
  update immediately.
- The choice is written to Quickshell's state path
  (`Quickshell.statePath("theme.json")`), which survives restarts.
- On startup the saved id is restored once that theme file has loaded.
- If the saved theme is missing or invalid, the default from
  `themes/presets/default.json` is used; if that is unavailable the built-in
  fallback palette is used.

## External synchronization hook

`config/Settings.qml` exposes:

```qml
property string externalThemeHook: ""
```

When non-empty, `ThemeManager` runs it detached as:

```bash
sh -c "<externalThemeHook> <theme-id>"
```

Use it to update Hyprland borders, GTK/Qt themes, icon themes or wallpaper
accent colors. It runs outside the Quickshell theme switch: a failing or missing
hook cannot interrupt or revert the palette change. `ThemeManager.themeApplied`
is also emitted for future integrations.

## Appearance overrides

The global settings application can apply non-destructive overrides on top of
the active theme. They are stored in `settings.json` and read by `Theme.qml`:

| Setting | Effect |
|---|---|
| Font family | Replaces the text font family; icon glyphs keep the theme's icon font |
| Text scale | Scales every typography size token |
| Corner radius scale | Scales the radius tokens used by every surface and control |
| Surface opacity | Replaces the theme opacity used by bar and popup backgrounds |
| Animations | Disables transitions or scales all theme animation durations |

The settings window itself uses the same `Theme` facade, so changing a theme or
an override updates the settings UI immediately. Custom themes in
`themes/custom/*.json` continue to appear automatically.

See [`SETTINGS.md`](SETTINGS.md) for the UI and persistence details.
