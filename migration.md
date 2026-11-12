# Noctalia to Quickshell Migration Guide

**Project name:** Phantom  
**Platform:** CachyOS + Hyprland + Wayland  
**Shell framework:** Quickshell + QML  
**Migration strategy:** Incremental replacement  
**Initial milestone:** Custom status bar

---

## 1. Project objectives

Replace Noctalia with a custom Quickshell-based desktop shell while retaining Hyprland as the window manager and compositor.

Phantom should provide the essential functionality of Noctalia without depending on Noctalia itself.

### Core principles

1. Implement the shell incrementally.
2. Keep all project files inside the designated project directory.
3. Maintain a modular and maintainable QML architecture.
4. Prefer native Quickshell integrations over external scripts.
5. Use Hyprland IPC for compositor-specific functionality.
6. Avoid unnecessary dependencies.
7. Document every additional system package installed.
8. Validate code before declaring any milestone complete.
9. Noctalia has been removed; Phantom is the only session shell.
10. Let the user perform final visual and behavioral acceptance testing.
11. Use `$HOME` for every file or directory path that points into the user's home directory. Never hardcode a username or an absolute `/home/<user>` path.
12. Treat Phantom as a standalone project. Do not couple it permanently to the dotfiles repository, a specific user name, or Noctalia's runtime files.

### Project identity

The shell is named **Phantom**. The long-term goal is a standalone repository and
installable desktop shell, not a subdirectory of a personal dotfiles repository.

For now the source lives outside the dotfiles repository at
`$HOME/Workspace/phantom-shell`, while it is developed alongside the Hyprland
configuration. The extraction, packaging and path plan is
documented in `docs/STANDALONE.md`. Runtime layer namespaces already use the
`phantom-*` prefix.

### Path policy

All file and directory references must be portable across users:

- Shell commands, Lua configuration, scripts and documentation use `$HOME`
  (for example `$HOME/Workspace/phantom-shell`).
- QML code must not contain `/home/<user>` literals. Resolve the home directory
  with `Quickshell.env("HOME")`, or use Quickshell's path helpers such as
  `Quickshell.shellDir`, `Quickshell.statePath()` and `Quickshell.configPath()`.
- Project-internal imports and file references stay relative to the project
  root.
- When documenting a command, write `$HOME/...` rather than a concrete user's
  home path.

### Definition of completion

A milestone is complete only when:

- All required files have been implemented.
- QML syntax and configuration are valid.
- Quickshell can load the configuration.
- No relevant runtime errors are present.
- The implemented functionality has been tested technically.
- Any known limitations are documented.

Do not claim that functionality works merely because the code was written.

---

## 2. Target environment

| Component | Choice |
|---|---|
| Linux distribution | CachyOS |
| Display server | Wayland |
| Window manager | Hyprland |
| Shell framework | Quickshell |
| UI framework | Qt Quick |
| UI language | QML |
| Compositor communication | Quickshell Hyprland integration |
| System communication | D-Bus |
| Package manager | pacman |

Hyprland remains responsible for:
- Window management.
- Workspace management.
- Keyboard shortcuts.
- Monitor management.
- Window focus.
- Compositor behavior.

Quickshell is responsible for:
- Status bar.
- Desktop panels.
- Launcher.
- Notifications UI.
- Control center.
- System widgets.
- Other desktop shell components.

---

## 3. Proposed project structure

All generated files must remain inside the project root.

```text
phantom/
│
├── shell.qml
│
├── config/
│   ├── Settings.qml
│   └── Theme.qml
│
├── services/
│   ├── Hyprland.qml
│   ├── Audio.qml
│   ├── Network.qml
│   ├── Bluetooth.qml
│   ├── Notifications.qml
│   └── SystemTray.qml
│
├── modules/
│   └── statusbar/
│       ├── StatusBar.qml
│       ├── LeftSection.qml
│       ├── CenterSection.qml
│       ├── RightSection.qml
│       │
│       ├── CalendarPopup.qml
│       ├── WorkspaceIndicator.qml
│       ├── SystemTray.qml
│       ├── PowerMenu.qml
│       ├── NotificationButton.qml
│       └── QuickSettings.qml
│
├── components/
│   ├── IconButton.qml
│   ├── Popup.qml
│   └── Tooltip.qml
│
├── assets/
│   ├── icons/
│   └── fonts/
│
├── docs/
│   ├── MIGRATION.md
│   ├── PACKAGES.md
│   └── TESTING.md
│
└── README.md
```

This is the proposed initial structure. Directories can be added as new modules are implemented.

Avoid creating abstractions prematurely. Introduce shared services when multiple components need the same functionality.

---

## Global Theming System — Mandatory Architecture Requirement

**Priority: Foundational**

Every component in the custom Quickshell shell must support centralized theming.

The theme system must be implemented early in the project, before developing the status bar and application launcher.

## Objectives

1. Support multiple predefined themes.
2. Allow users to create and install custom themes.
3. Provide a theme switcher.
4. Apply theme changes across all shell components immediately.
5. Persist the selected theme across reboots.
6. Ensure consistent colors, typography, spacing, radii and component styling.
7. Avoid hardcoded visual properties inside individual components.

## Architecture

Create a centralized theme management system.

Suggested structure:

```text
themes/
├── ThemeManager.qml
├── Theme.qml
├── ThemeLoader.qml
├── palettes/
│   ├── catppuccin-mocha.json
│   ├── tokyo-night.json
│   ├── nord.json
│   ├── dracula.json
│   └── rose-pine.json
└── presets/
    └── default.json
```

### ThemeManager

Responsible for:

- Loading themes.
- Tracking the active theme.
- Switching themes.
- Validating theme files.
- Providing fallback themes.
- Persisting the selected theme.
- Notifying dependent components about changes.

### Theme tokens

Every theme should define a consistent schema containing:

**Colors**
- Background
- Surface
- Elevated surface
- Primary
- Secondary
- Tertiary
- Foreground
- Muted foreground
- Disabled
- Border
- Success
- Warning
- Error
- Info

**Typography**
- Font family
- Font sizes
- Font weights
- Line heights

**Spacing**
- Extra small
- Small
- Medium
- Large
- Extra large

**Component styling**
- Border radius
- Border width
- Padding
- Shadows
- Opacity

**Animation**
- Fast duration
- Normal duration
- Slow duration
- Standard easing curves

## Theme switcher UI

Implement a dedicated theme selection interface.

Requirements:

- Display available themes.
- Display theme names and previews.
- Highlight the currently selected theme.
- Apply themes without restarting Quickshell.
- Persist the active theme.
- Support custom themes.
- Validate themes before applying them.
- Retain the previous valid theme if loading fails.

## Component requirements

Every shell component must use centralized theme tokens.

This applies to:

- Status bar.
- Calendar.
- Workspace indicators.
- System tray.
- Launcher.
- Control center.
- Notification center.
- Dock.
- OSD.
- Power menu.
- Lock screen.
- Desktop widgets.
- All reusable UI components.

Never hardcode theme-dependent colors, font properties, spacing or border radii in individual components.

## External theme synchronization

Provide an optional theme-change hook for synchronizing:

- Hyprland active/inactive window borders.
- GTK theme.
- Qt theme.
- System icon theme.
- Wallpaper or accent color integrations.

Keep external synchronization independent of the core Quickshell theme system.

Failure to update an external application theme must not break the Quickshell theme switch.

## Validation

Test the following:

1. Switch between all installed themes.
2. Verify every existing module updates.
3. Restart Quickshell and verify the selected theme persists.
4. Restart the system and verify theme persistence.
5. Load an invalid theme and verify fallback behavior.
6. Add a custom theme without modifying component QML files.
7. Verify no component contains unintended hardcoded theme values.
8. Verify switching themes does not create duplicate windows or reset unrelated runtime state.

**Acceptance criterion:** Adding a new valid theme must not require modifying the status bar, launcher, calendar or any other UI component. The theme manager must be the only component responsible for applying the palette.

# 4. Development milestones

## Milestone 0: Environment preparation

Before writing the shell:

1. Check the installed Quickshell version.
2. Check whether the Quickshell Hyprland integration is available.
3. Inspect the existing Hyprland configuration.
4. Identify existing Noctalia startup commands.
5. Identify existing notification and system tray services.
6. Check whether required packages are already installed.

Useful commands:

```bash
hyprctl version
hyprctl monitors
hyprctl workspaces

qs --version
qs --help

pacman -Q quickshell
```

Do not overwrite the existing Hyprland configuration.

Create a backup before introducing new keybindings or startup changes.

### Package installation policy

Prefer the existing packages available in CachyOS repositories.

Check availability before installing:

```bash
pacman -Si quickshell
```

Install only packages that are genuinely missing.

Every additional package must be documented in `docs/PACKAGES.md` with:

- Package name.
- Reason for installation.
- Which feature requires it.
- Whether it is mandatory or optional.

Do not install alternative implementations of functionality already provided by Quickshell.

---

## Milestone 1: Status bar

**Priority: Highest**

Build a custom status bar with three logical sections.

### 1.1 Layout

```text
┌──────────────────────────────────────────────────────────────┐
│                                                              │
│  ┌──────────────┐  ┌──────────────────┐  ┌────────────────┐  │
│  │ Date / Time │  │ 1  2  3  4  5  6 │  │ Tray / WiFi /  │  │
│  │              │  │                  │  │ BT / Notify /  │  │
│  │              │  │                  │  │ Power          │  │
│  └──────────────┘  └──────────────────┘  └────────────────┘  │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

The bar must:

- Have a configurable gap from the left and right screen edges.
- Not extend across the entire screen width.
- Have configurable height.
- Have rounded corners.
- Be horizontally centered.
- Support a configurable top or bottom position.
- Use a Wayland layer-shell surface.
- Stay above normal application windows.
- Support multiple monitors.

Use a single background container with three logical sections.

The left and right sections should have consistent padding, while the workspace section remains centered relative to the screen rather than merely centered in the remaining space.

### 1.2 Left section: Date and time

Display:

- Current time.
- Current date.

Example:

```text
Fri, Nov 06    07:30 PM
```

Clicking the date/time should open a calendar popup.

#### Calendar requirements

- Display the current month.
- Previous and next month navigation.
- Highlight today's date.
- Highlight the selected date.
- Display weekday names.
- Allow selecting dates.
- Provide a button to return to today.
- Close when clicking outside.
- Position the popup relative to the date/time widget.

Use a native QML calendar implementation where possible. Avoid introducing an external calendar application just to render a calendar popup.

Initial scope is a functional calendar UI; external calendar synchronization is not required.

The implemented calendar flyout is a wider glass panel with a live clock and
seconds, long date, week number, adjacent-month days, today and selected-date
states, and current weather from wttr.in. The weather location can be set in
`Settings.weatherLocation`; an empty value uses IP-based detection. Notifications and event lists are not embedded;
notification state remains in the separate notification system.

### 1.3 Center section: Workspace indicator

Display the available numbered workspaces.

Example:

```text
 1   2   3   4   5   6
```

Requirements:

- Workspace numbering starts at 1.
- Display workspaces that exist in Hyprland.
- Highlight the currently active workspace.
- Clicking a workspace switches to it.
- Workspace state updates automatically when Hyprland changes.
- Support workspaces created after the shell starts.
- Do not display special workspaces as ordinary numbered workspaces.

Use Quickshell's native Hyprland workspace integration.

Avoid periodically polling `hyprctl` when an event-driven integration is available.

#### Workspace keyboard shortcuts

The SUPER (Windows) key will be the primary modifier for the shell's global shortcuts.

Required behavior:

| Shortcut | Action |
|---|---|
| SUPER + 1 | Switch to workspace 1 |
| SUPER + 2 | Switch to workspace 2 |
| SUPER + 3 | Switch to workspace 3 |
| ... | ... |
| SUPER + 9 | Switch to workspace 9 |

If a workspace does not exist, Hyprland should create it when the workspace is activated.

Add these shortcuts to the Hyprland configuration rather than trying to capture the SUPER modifier inside the QML application.

The SUPER key will also be the foundation for future shell shortcuts, including:

- SUPER + Space: Application launcher.
- SUPER + A: Control center.
- SUPER + N: Notification center.
- SUPER + Escape: Power menu.

Avoid duplicate keybindings with existing Hyprland configuration.

### 1.4 Right section: System controls

The right section should contain the following elements.

#### System tray

Display background application applets.

Requirements:

- Support StatusNotifierItem-compatible applications.
- Display application icons.
- Support left-click and right-click interactions where provided by the tray application.
- Show application context menus.
- Handle applications appearing and disappearing dynamically.
- Avoid displaying duplicate tray entries.

This is intended for background applications such as clipboard managers, chat clients and other applications that expose tray icons.

Keep the implementation modular so the tray can be reused in other panels.

#### Notification button

Display an icon indicating notifications.

Requirements:

- Clicking opens the notification center.
- Indicate when notifications are available.
- Support Do Not Disturb state.
- Future integration with notification history.

The actual notification daemon implementation can be addressed in a later milestone.

#### Network button

Display the current network status.

Requirements:

- Show Wi-Fi or Ethernet status.
- Indicate disconnected state.
- Clicking opens quick network settings.

#### Bluetooth button

Display Bluetooth status.

Requirements:

- Indicate whether Bluetooth is enabled.
- Clicking opens Bluetooth controls.

#### Audio button

Display the current audio state.

Requirements:

- Show mute state or volume indicator.
- Clicking opens audio controls.

#### Power button

Open a popup containing:

- Lock screen.
- Logout.
- Suspend.
- Reboot.
- Shutdown.

These actions must use appropriate system/session APIs and must not be simulated UI interactions.

---

### 1.5 Bar module groups

The status bar is organized as independent modules:

- Date/time.
- Workspaces.
- Control center group: the system tray, the configurable system controls and
  the control center button.

The bar UI is pluggable. `barStyle` selects between two layouts:

- `classic`: one rounded bar with date/time, workspaces and the control center
  group. The group can be placed on the left or right.
- `pills`: floating pills for the logo, workspace pager, pinned apps, centered
  clock, status controls, and separate control center/power buttons.

Both layouts share the same services, icon order, visibility settings and drag
reordering. In the pills layout the configurable controls live in the status
pill and Power is a separate round button. The selected style is persisted in
`bar.json` and older per-button settings are migrated automatically.

Date/time and workspace modules are intentionally fixed for now. They are
independent modules and may become movable in a later iteration; the classic
layout already supports per-group positioning of the control center group.

## Milestone 2: Shared shell infrastructure

Once the initial bar works, extract common functionality into reusable services.

Expected services:

| Service | Responsibility |
|---|---|
| Hyprland | Workspace and compositor state |
| Audio | Audio devices and volume |
| Network | Network status and connections |
| Bluetooth | Bluetooth devices and state |
| Notifications | Notification state and history |
| SystemTray | Background application applets |

All services should expose reactive properties and reusable methods.

UI components must not independently implement system integrations.

---
# Milestone 3: Control Center — Widget-Based Quick Settings

**Priority: High**

## 1. Objective

Build a compact, visually appealing control center using independent widgets/cards.

The control center must NOT be implemented as a conventional settings page containing long, vertically stacked lists of all available devices, networks, audio sources or wallpapers.

Instead, it should provide an overview of available system controls. Individual widgets should open their respective detailed management interfaces when clicked.

The design should follow a dashboard-based approach with compact cards, clear visual grouping and consistent spacing.

## 2. Core interaction principles

1. The initial control center view must display an overview of system controls.
2. Each system feature must have its own independent widget.
3. Clicking a widget should open its dedicated detail view.
4. Detailed device lists and configuration options must not be displayed directly in the overview.
5. Reuse existing system management components wherever available.
6. Do not implement the same system integration or UI functionality twice.
7. Support quick actions such as toggling Wi-Fi, Bluetooth, Night Light and Do Not Disturb directly from the overview where appropriate.
8. The control center must use the global theme manager.

## 3. Control center overview

Organize the following widgets into a responsive grid.

### Connectivity

**Wi-Fi widget**
- Display current connection state.
- Display connected network name.
- Provide a quick enable/disable action.
- Clicking the widget opens the existing Wi-Fi management interface.

**Bluetooth widget**
- Display Bluetooth enabled/disabled state.
- Display the number of connected devices.
- Provide a quick enable/disable action.
- Clicking the widget opens the existing Bluetooth management interface.

### Audio

**Audio widget**
- Display current output device.
- Display current volume.
- Optionally provide a compact volume slider.
- Clicking the widget opens the detailed audio interface.

The detailed interface should support:
- Output device selection.
- Input device selection.
- Master volume.
- Microphone volume.
- Mute controls.
- Per-application volume where supported.

Do not display all audio devices in the overview.

### Display

**Brightness widget**
- Display current brightness.
- Provide a compact slider.
- Support multiple displays where possible.

**Night Light widget**
- Display enabled/disabled state.
- Provide a quick toggle.
- Clicking the widget opens additional configuration if supported.

### Power and battery

**Battery widget**
- Display battery percentage.
- Display charging/discharging state.
- Show estimated remaining time when available.
- Clicking opens detailed battery information.

**Power Profile widget**
- Display current power profile.
- Clicking opens available power profiles.
- Allow switching between profiles.

### Notifications

**Do Not Disturb widget**
- Display current state.
- Provide a quick toggle.
- Clicking can open additional notification settings.

### Appearance

**Theme widget**
- Display the currently selected theme.
- Display a small theme preview.
- Clicking opens the theme selector.

The theme selector must use the global ThemeManager.

**Wallpaper widget**
- Display the current wallpaper thumbnail.
- Clicking opens the dedicated wallpaper selector.

Do not display a grid of every available wallpaper inside the control center overview.

The wallpaper selector should be a separate interface supporting previews and selection.

## 4. Detail view behavior

Every widget that provides detailed management functionality must have a dedicated detail view.

Examples:

- Wi-Fi card → Wi-Fi management.
- Bluetooth card → Bluetooth management.
- Audio card → Audio management.
- Appearance card → Theme selector.
- Wallpaper card → Wallpaper selector.
- Power profile card → Power profile selector.

Detail views should:

- Open as a popup, subpanel or dedicated overlay.
- Have a clear title.
- Provide a back/close action.
- Support appropriate keyboard navigation.
- Close when Escape is pressed.
- Use the same global theme.
- Avoid unnecessary nested scrolling.

Only one detail view should be active at a time unless there is a clear reason to support multiple independent popups.

## 5. Reuse existing functionality

Some controls already have dedicated buttons in the status bar.

Do not remove or replace those buttons.

Instead, expose the same functionality through the control center.

For example:

```text
Status Bar Bluetooth Button ─────┐
                                │
                                ├── Bluetooth Service
                                │
Control Center Bluetooth Card ──┘
                                │
                                └── Bluetooth Detail View
```

Both entry points must use the same service and detail component.

Apply the same architecture to:

- Wi-Fi.
- Bluetooth.
- Audio.
- Notifications.
- Other existing controls.

The theme selector is an exception: move its primary entry point into the control center rather than keeping a separate theme button in the status bar.

## 6. Layout and visual requirements

- Use a compact responsive card grid.
- Prefer two or three columns depending on available width.
- Avoid a permanently scrollable overview.
- Keep card heights reasonably consistent.
- Use clear icons and short descriptions.
- Display important system state without overwhelming the interface.
- Provide subtle hover and pressed states.
- Use consistent component spacing and border radii.
- Support keyboard navigation and accessibility.
- Support multiple monitors.
- Ensure all cards follow the currently active global theme.

The control center should be visually closer to a compact desktop dashboard than a traditional settings application.

## 7. Technical architecture

Suggested structure:

```text
modules/
└── control-center/
    ├── ControlCenter.qml
    ├── ControlCenterGrid.qml
    │
    ├── widgets/
    │   ├── WifiWidget.qml
    │   ├── BluetoothWidget.qml
    │   ├── AudioWidget.qml
    │   ├── BrightnessWidget.qml
    │   ├── BatteryWidget.qml
    │   ├── PowerProfileWidget.qml
    │   ├── NightLightWidget.qml
    │   ├── DoNotDisturbWidget.qml
    │   ├── ThemeWidget.qml
    │   └── WallpaperWidget.qml
    │
    └── views/
        ├── WifiView.qml
        ├── BluetoothView.qml
        ├── AudioView.qml
        ├── ThemeSelector.qml
        └── WallpaperSelector.qml
```

These views must consume the shared services:

- Network service.
- Bluetooth service.
- Audio service.
- Battery service.
- Power profile service.
- Notification service.
- Theme manager.
- Wallpaper service.

Do not duplicate system integrations inside individual widgets.

## 8. Testing and acceptance criteria

Verify:

1. Control center opens without QML errors.
2. Overview displays all configured widgets.
3. Widgets display actual system state.
4. Wi-Fi card opens the existing Wi-Fi interface.
5. Bluetooth card opens the existing Bluetooth interface.
6. Audio card opens the existing audio interface.
7. Theme selection updates the entire shell.
8. Wallpaper selection updates the desktop.
9. Quick toggles update actual system state.
10. Status bar buttons and control center widgets remain synchronized.
11. No duplicate Bluetooth, network or audio implementations exist.
12. No long device lists appear in the initial overview.
13. Detail views open and close correctly.
14. The layout follows the active global theme.

**Acceptance criterion:** The control center must initially feel like a compact dashboard. Detailed system configuration should only appear after the user explicitly opens the corresponding widget.
---


# Milestone 4: Global Settings Application

**Priority: High**

## 1. Objective

Build a centralized settings application for Phantom.

The settings application should allow users to configure the appearance, behavior and functionality of all Phantom modules from one place.

This must be a dedicated settings interface, separate from the Control Center.

The Control Center provides quick access to system controls, whereas the Global Settings application manages persistent shell configuration.

Examples:

- Control Center: Toggle a feature or select a quick setting.
- Global Settings: Configure how that feature behaves and appears.

The settings application must follow the global ThemeManager so its appearance changes whenever the active theme changes.

## 2. UI and layout requirements

Create a centered settings window using Quickshell.

### Window positioning

- Appear in the center of the active monitor.
- Use a floating window/panel style.
- Have configurable width and height.
- Have rounded corners.
- Use the global theme.
- Support smooth opening and closing animations.
- Close using Escape.
- Support outside-click dismissal where appropriate.
- Support multiple monitors.
- Keep the window within the available screen area.

### Main layout

Use a two-column layout:

| Section | Width |
|---|---:|
| Left sidebar | 30% |
| Right content area | 70% |

The proportions should be configurable, with 30/70 as the default.

### Left sidebar

The sidebar should contain navigation categories with icons and labels.

Required categories:

1. Panel
2. Appearance
3. Date & Time
4. Calendar
5. Control Center
6. Launcher
7. Notifications
8. Wallpaper
9. Keyboard Shortcuts
10. Advanced

Requirements:

- Clearly highlight the selected category.
- Show the category icon and name.
- Allow switching between categories.
- Preserve the current category when changing settings.
- Support keyboard navigation.
- Allow the sidebar to scroll independently if required.
- Include a settings search option if practical.

### Right content area

When a sidebar category is selected, display its settings in the right section.

Requirements:

- Display a clear category heading.
- Provide a short description.
- Organize settings into logical groups.
- Use consistent labels and descriptions.
- Use appropriate controls such as switches, sliders, dropdowns, segmented controls, color pickers and text inputs.
- Avoid overwhelming the user with too many settings at once.
- Support independent scrolling when necessary.

Settings should be grouped into cards or sections rather than displayed as an unstructured list.

## 3. Settings categories and functionality

### A. Panel

Allow configuration of the Phantom status bar.

#### General

- Enable/disable the status bar.
- Select bar style (Classic / Pills).
- Select top or bottom position.
- Set bar height.
- Set left and right screen margins.
- Configure horizontal alignment.
- Set corner radius.
- Set internal padding.
- Configure opacity and transparency.

#### Modules

Allow configuration of individual bar modules.

- Date and time.
- Workspace indicator.
- System tray.
- Network indicator.
- Bluetooth indicator.
- Audio indicator.
- Notification button.
- Control Center button.
- Power button.

Allow users to:

- Show/hide modules.
- Change module order where supported.
- Configure module spacing.
- Configure individual module appearance.
- Reset module configuration.

Preserve the existing bar layout and drag-reordering functionality.

Do not break the existing `bar.json` configuration or discard user customizations.

### B. Appearance

Manage the overall visual appearance of Phantom.

#### Themes

- List installed themes.
- Display theme previews.
- Select active theme.
- Support custom themes.
- Apply themes immediately.
- Persist the selected theme.

#### Typography

- Font family.
- Font size.
- Font weight.
- Icon font where applicable.

#### Interface appearance

- Interface density (Compact / Comfortable / Spacious).
- Border radius.
- Shadows.
- Transparency.
- Blur intensity where supported.
- Animation enable/disable.
- Animation speed.

All appearance settings must use the shared ThemeManager and design tokens.

Avoid implementing separate theme configuration inside individual modules.

### C. Date & Time

Configure the date and time display in the status bar.

#### Clock

- 12-hour / 24-hour format.
- Show/hide seconds.
- Show/hide AM/PM.
- Custom time format.
- Timezone display.
- Show/hide clock.

#### Date

- Custom date format.
- Short/long date format.
- Show/hide weekday.
- Show/hide year.
- Configure date and time ordering.

Provide a preview of the selected date/time format.

Use the system's actual local time unless the user explicitly configures another display timezone.

Changing display timezone must not change the operating system's system timezone.

### D. Calendar

Configure the calendar popup opened from the status bar.

Settings:

- First day of the week (Sunday / Monday / Custom).
- Show/hide week numbers.
- Show/hide adjacent month dates.
- Highlight today's date.
- Calendar popup dimensions.
- Calendar appearance.
- Date selection behavior.
- Configurable week-start convention.

Where appropriate, allow calendar appearance to inherit from the global theme.

Provide a preview of the calendar configuration.

### E. Control Center

Configure the widget-based Control Center.

Allow users to:

- Enable/disable individual widgets.
- Reorder widgets.
- Configure the number of columns.
- Configure card spacing.
- Configure panel dimensions.
- Configure widget appearance.
- Configure quick-toggle availability.

Widgets include:

- Wi-Fi.
- Bluetooth.
- Audio.
- Brightness.
- Battery.
- Power profiles.
- Night Light.
- Do Not Disturb.
- Theme selector.
- Wallpaper selector.

Do not duplicate system service configuration here. These settings should control presentation and behavior, not reimplement the actual system integrations.

### F. Launcher

This category should be prepared for the future application launcher milestone.

Potential settings:

- Launcher width and height.
- Position.
- Application icon size.
- Search behavior.
- Search result limit.
- Fuzzy matching.
- Recent applications.
- Enabled search providers.
- Default search provider.
- Keyboard navigation behavior.

Only expose settings for functionality that has actually been implemented.

### G. Notifications

Prepare this category for the future notification milestone.

Potential settings:

- Popup position.
- Popup timeout.
- Maximum visible notifications.
- Notification history limit.
- Grouping by application.
- Application-specific notification behavior.
- Do Not Disturb preferences.
- Urgency-based popup behavior.

The notification service must remain the single source of truth.

### H. Wallpaper

Configure wallpaper-related functionality.

Settings:

- Wallpaper directories.
- Default wallpaper.
- Wallpaper scaling mode.
- Transition animation.
- Transition duration.
- Random wallpaper behavior.
- Multi-monitor wallpaper behavior.

The actual wallpaper selector remains accessible from the Control Center.

### I. Keyboard Shortcuts

Provide a centralized place to view and configure Phantom keyboard shortcuts.

Examples:

| Shortcut | Action |
|---|---|
| SUPER + SPACE | Application launcher |
| SUPER + A | Control Center |
| SUPER + N | Notification center |
| SUPER + T | Theme switching |
| SUPER + , | Global settings |

Requirements:

- Display all registered Phantom shortcuts.
- Allow changing shortcuts where supported.
- Detect conflicts.
- Clearly distinguish Hyprland-managed shortcuts from internal shell shortcuts.
- Persist custom shortcuts.
- Never silently overwrite existing Hyprland bindings.

Hyprland-managed shortcuts should be modified through a safe configuration mechanism rather than directly rewriting the user's entire Hyprland configuration.

### J. Advanced

Provide advanced configuration and maintenance options.

Potential features:

- Configuration directory information.
- Current Phantom version.
- Quickshell version.
- Configuration validation.
- Debug logging.
- Diagnostics.
- Reset individual category.
- Reset all Phantom settings.
- Export configuration.
- Import configuration.
- Restore defaults.

Provide confirmation before destructive reset operations.

## 4. Configuration architecture

The settings UI must not directly own or duplicate configuration state.

Create a centralized configuration management layer.

Suggested structure:

```text
config/
├── ConfigManager.qml
├── Settings.qml
├── Defaults.qml
├── Schema.qml
└── migrations/
    └── ...

modules/
└── settings/
    ├── SettingsWindow.qml
    ├── SettingsSidebar.qml
    ├── SettingsContent.qml
    ├── SettingsNavigation.qml
    │
    └── pages/
        ├── PanelSettings.qml
        ├── AppearanceSettings.qml
        ├── DateTimeSettings.qml
        ├── CalendarSettings.qml
        ├── ControlCenterSettings.qml
        ├── LauncherSettings.qml
        ├── NotificationSettings.qml
        ├── WallpaperSettings.qml
        ├── ShortcutSettings.qml
        └── AdvancedSettings.qml
```

### Configuration principles

1. Every module must consume configuration from the centralized configuration manager.
2. Settings changes should update the corresponding module reactively.
3. Persist configuration across shell restarts.
4. Validate values before saving.
5. Provide sensible defaults.
6. Handle missing or invalid configuration files gracefully.
7. Support future configuration schema migrations.
8. Avoid storing settings separately inside individual QML components.

Use modular configuration files where appropriate, rather than one enormous configuration file.

For example:

```text
config/
├── general.json
├── appearance.json
├── bar.json
├── datetime.json
├── calendar.json
├── control-center.json
├── launcher.json
├── notifications.json
├── wallpaper.json
└── shortcuts.json
```

The configuration manager should provide a unified interface regardless of how settings are physically stored.

Use `$HOME`-portable paths and Quickshell's configuration/state path helpers. Never hardcode a username or absolute home directory.

### Saving behavior

- Apply ordinary settings immediately.
- Persist changes safely.
- Avoid writing configuration files on every animation frame or slider movement.
- Debounce frequent updates such as slider adjustments.
- Provide a reset-to-default option.
- Handle failed writes without corrupting existing configuration.

## 5. Settings window entry point

Add a global shortcut:

`SUPER + ,` → Open Phantom Settings.

Also provide an entry point from:

- Control Center settings icon.
- Future launcher search.
- Other appropriate shell menus.

All entry points must open the same settings window instance.

Do not create duplicate settings windows.

## 6. Global theme integration

The settings application itself must be fully themeable.

Every setting component should use shared design tokens.

This includes:

- Sidebar.
- Navigation items.
- Cards.
- Switches.
- Sliders.
- Dropdowns.
- Inputs.
- Tooltips.
- Section headings.
- Dialogs.
- Preview components.

Changing the active theme must update the entire settings interface immediately.

Adding a new theme must not require changes to settings page QML files.

## 7. Testing requirements

Verify:

1. Settings window opens centered on the active monitor.
2. Sidebar uses the 30/70 layout.
3. All implemented categories are accessible.
4. Selecting a category updates the right content area.
5. Settings are grouped and

### Implementation status

The core settings application is implemented:

- `modules/settings/SettingsWindow.qml` provides the centered, themed,
  full-screen overlay with a 30/70 sidebar/content split and outside-click and
  Escape dismissal.
- `SettingsSidebar.qml`, `SettingsContent.qml` and `pages/` implement all ten
  required categories. Panel, Appearance, Date & Time, Calendar, Control Center,
  Wallpaper, Keyboard Shortcuts and Advanced are functional; Launcher and
  Notifications are placeholders for their milestones.
- `config/Settings.qml` is the centralized store. Bar geometry and module order
  persist in `bar.json`; date/time, calendar, appearance, wallpaper, control
  center and window options persist in `settings.json`; theme and wallpaper
  paths remain in `theme.json` and `wallpaper.json`.
- Appearance overrides flow through `Theme.qml` (font family, text scale,
  radius scale, opacity and animation speed).
- Entry points: `SUPER + ,`, the control center gear and the `phantom` IPC
  target (`settings` and `toggleSettings`). All use one window instance.
- Reusable settings components live in `components/Settings*.qml`; theme and
  wallpaper selection reuse the existing `ThemePicker`, `WallpaperPicker`,
  `ThemeManager` and `Wallpapers` implementations.
- Advanced includes diagnostics, per-category resets and a confirmed reset-all.

Deferred: launcher/notification settings, shortcut editing (read-only because
Hyprland bindings are not rewritten), configuration import/export and
per-monitor wallpapers. These are documented in `docs/SETTINGS.md`.

# Milestone 5: Notification Center and Notification Popups

**Priority: High**

## Objective

Implement a complete custom notification experience using Quickshell.

The implementation should follow the supplied visual reference: a floating notification center containing Do Not Disturb controls, a media player and notification cards.

The notification center must not be a conventional notification list with no structure.

It should be a polished desktop panel with independent sections.

## 1. Notification architecture

Use Quickshell's native NotificationServer integration through:

```qml
import Quickshell.Services.Notifications
```

The shell should own the notification service and provide a shared notification store.

The architecture should look like:

```text
Applications
     |
     v
NotificationServer
     |
     v
NotificationService
     |
     ├── Notification History
     |
     ├── Notification Popups
     |
     ├── Notification Center
     |
     └── Do Not Disturb State
```

Only one process should own the freedesktop notification service.

Do not run multiple competing notification daemons.

## 2. Notification center UI

Create a floating panel positioned on the right side of the active monitor.

Requirements:

- Configurable width and height.
- Rounded corners.
- Theme-aware background.
- Appropriate transparency and blur where supported.
- Smooth opening and closing animations.
- Independent scrolling for notification history when necessary.
- Close on Escape.
- Close on outside click.
- Support multiple monitors.

The panel should contain three independent sections.

### A. Header and Do Not Disturb

Display:

- Notification center heading.
- Settings button.
- Do Not Disturb toggle.

DND must be controlled through the shared notification service.

### B. Media player

Display the currently active MPRIS media player.

Requirements:

- Album artwork.
- Track title.
- Artist name.
- Play/pause.
- Previous/next track.
- Shuffle.
- Repeat.
- Playback progress where practical.

Automatically hide the section if no supported media player is available.

Do not implement a separate media player backend.

### C. Notification history

Display actual notifications received from applications.

Each notification card should contain:

- Application icon.
- Application name.
- Notification title.
- Notification body.
- Timestamp.
- Available notification actions.
- Dismiss control.

Support:

- Grouping by application.
- Expand/collapse groups.
- Individual dismissal.
- Clear all notifications.
- Notification actions.
- Inline replies where supported.
- Urgency indicators.

Display the most recent notifications first.

Provide a sensible maximum history size configurable by the user.

Persist notification history so that it survives Quickshell reloads and, where practical, system restarts.

Transient notifications should not be stored in persistent history when their protocol flags require otherwise.

## 3. Notification popups

Implement a separate notification popup layer.

When an application sends a notification:

1. Receive it through NotificationServer.
2. Store it in the notification service.
3. Update the notification center.
4. Display a popup unless DND suppresses it.
5. Automatically dismiss the popup after its timeout.

Requirements:

- Floating notification cards.
- Configurable screen position.
- Automatic dismissal.
- Manual dismissal.
- Multiple notification support.
- Urgency-based styling.
- Application icons.
- Notification actions.
- Smooth animations.
- Consistent global theming.

Critical notifications should receive special treatment.

Notification popup dismissal must not automatically delete the corresponding notification from history.

## 4. Shared state and integration

The notification service must be the single source of truth.

The following components must use the same service:

- Status bar notification button.
- Notification center.
- Control center DND widget.
- Notification popup layer.

Synchronize:

- Unread notification count.
- Notification history.
- DND state.
- Active popup count.

Do not create separate notification state inside each UI component.

## 5. Suggested project structure

```text
services/
└── NotificationService.qml

modules/
└── notifications/
    ├── NotificationCenter.qml
    ├── NotificationCenterHeader.qml
    ├── NotificationHistory.qml
    ├── NotificationGroup.qml
    ├── NotificationCard.qml
    ├── NotificationActions.qml
    ├── NotificationPopupLayer.qml
    ├── NotificationPopup.qml
    ├── DoNotDisturb.qml
    └── MediaPlayerWidget.qml
```

## 6. Global theming

All notification components must use the shared ThemeManager.

Theme properties should cover:

- Notification card background.
- Popup background.
- Application icon presentation.
- Urgency colors.
- Text colors.
- Border radius.
- Spacing.
- Shadows.
- Animation durations.
- Media player artwork presentation.

Do not hardcode component colors.

## 7. Keyboard shortcuts

Suggested shortcuts:

| Shortcut | Action |
|---|---|
| SUPER + N | Toggle notification center |
| SUPER + SHIFT + N | Toggle Do Not Disturb |

The status bar notification button should also toggle the same notification center.

## 8. Testing requirements

Test with real notifications.

Examples:

```bash
notify-send "Test notification" "Hello from Quickshell"
notify-send -u low "Low priority" "Test message"
notify-send -u critical "Critical notification" "Important message"
```

Verify:

1. Applications can send notifications.
2. Notifications appear as popups.
3. Notifications appear in history.
4. Popup timeout works.
5. Individual dismissal works.
6. Clear all works.
7. Notification actions work where supported.
8. DND suppresses ordinary popups.
9. Critical notifications follow configured policy.
10. Notification history survives shell reload.
11. Media player integration works with an actual MPRIS player.
12. Status bar and control center reflect the same notification state.
13. No competing notification daemons are running.
14. All components respect the active theme.

Do not mark this milestone complete until Quickshell has been technically tested with real application notifications.

---

## Milestone 5: Application launcher

Build a native Quickshell application launcher using QML.

The launcher must not depend on Noctalia or an external launcher application.

### UI requirements

- Center the launcher on the active monitor.
- Use a floating popup with rounded corners.
- Provide a search input at the top.
- Display application icons and names.
- Support keyboard navigation.
- Highlight the currently selected result.
- Close when Escape is pressed.
- Close after launching an application.
- Close when clicking outside.
- Support configurable width, height and theme.

### Application discovery

Use Quickshell's native DesktopEntries integration to discover installed applications.

Requirements:

- Discover installed desktop applications.
- Read application names and icons.
- Support application launching.
- Exclude hidden and NoDisplay applications.
- Handle applications being installed or removed.
- Avoid maintaining a separate application database unless required.

### Search functionality

Implement:

- Application name search.
- Application description search.
- Keyword search.
- Category filtering.
- Fuzzy matching.
- Case-insensitive matching.

### Keyboard shortcuts
bind the keymap using Hyprland keymap config

| Shortcut | Action |
|---|---|
| SUPER + SPACE | Open launcher |
| Arrow Up / Down | Navigate results |
| Enter | Launch selected application |
| Escape | Close launcher |
| Ctrl + Backspace | Clear search |

### Additional search providers

Keep the launcher extensible through independent search providers.

Initial providers:

1. Applications.
2. Calculator.
3. Shell commands.
4. Web search.

Future providers may include:

- Clipboard history.
- Running windows.
- Custom user-defined commands with some predefine commands like shutdown, lock, suspend etc

### Architecture

Keep launcher functionality separate from the status bar.

Suggested structure:

```text
modules/
└── launcher/
    ├── Launcher.qml
    ├── LauncherInput.qml
    ├── LauncherResults.qml
    ├── LauncherDelegate.qml
    ├── LauncherManager.qml
    └── providers/
        ├── ApplicationProvider.qml
        ├── CalculatorProvider.qml
        ├── CommandProvider.qml
        └── WebSearchProvider.qml
```

Use a Quickshell IPC handler or global shortcut to expose launcher toggling.

### Testing

- Verify application discovery.
- Verify icons load correctly.
- Verify search filtering.
- Verify fuzzy matching.
- Verify keyboard navigation.
- Verify application execution.
- Verify launcher opens on the active monitor.
- Verify Escape and outside-click dismissal.
- Verify no duplicate launcher instances.

Do not mark the milestone complete until the launcher loads without QML errors and its application discovery and launch functionality have been technically tested.

Implement:

- Application discovery through XDG Desktop Entry.
- Application search.
- Application launching.
- Fuzzy matching.
- Keyboard navigation.
- Recent applications.
- Calculator support.
- Command execution.

Use SUPER + Space to open the launcher.

---

## Milestone 6: Additional shell functionality

Potential future features:

- Dock.
- Clipboard history.
- Wallpaper selector.
- Media player controls.
- Lock screen.
- OSD.
- Desktop widgets.
- Theme customization.
- Configuration UI.
- Multi-monitor customization.

These features should not delay completion of the initial status bar.

---

# 5. Testing requirements

Testing is mandatory throughout development.

Do not wait until the entire shell has been implemented.

### 5.1 Static validation

For every milestone:

- Check QML syntax.
- Check component imports.
- Check property names and types.
- Check missing component references.
- Check invalid bindings.
- Check configuration paths.

Use Quickshell's available linting and QML tooling where appropriate.

### 5.2 Runtime validation

Start the shell independently during development.

```bash
qs -p ./shell.qml
```

Use the actual project entry point and verify the supported command-line options against the installed Quickshell version.

Check logs for:

- QML errors.
- Missing modules.
- Missing files.
- Invalid properties.
- D-Bus errors.
- Failed system integrations.

### 5.3 Functional validation

For the status bar, verify:

| Test | Expected result |
|---|---|
| Start shell | Bar appears |
| Date/time | Correct current time |
| Click date/time | Calendar opens |
| Navigate calendar | Month changes |
| Click workspace 2 | Workspace 2 becomes active |
| SUPER + 3 | Workspace 3 becomes active |
| SUPER + 9 | Workspace 9 is created if needed and activated |
| Switch workspace externally | Bar updates automatically |
| Connect Bluetooth | Indicator updates |
| Change audio volume | Audio state updates |
| Open tray application | Its applet appears |
| Click power button | Power menu opens |
| Multiple monitors | Correct bar appears on each screen |

### 5.4 Completion report

At the end of each milestone, provide:

1. Files created.
2. Files modified.
3. Packages installed.
4. Validation commands executed.
5. Validation results.
6. Known issues.
7. Features ready for user testing.

Clearly distinguish between:
- Syntax validated.
- Runtime tested.
- System integration tested.
- User behavior verified.

Do not claim user behavior has been verified unless it has actually been tested.

---

# 6. Migration status and rollback

The Noctalia shell has been removed from the session and its user files have
been removed. The `noctalia-shell` package still needs to be uninstalled; the
command is below. `noctalia-qs` remains only as the Quickshell runtime that
provides `qs`.

### Removed integration

- The Noctalia autostart command and compositor layer rule.
- The Noctalia IPC keybindings. `SUPER + SPACE` now starts `hyprlauncher`.
- Noctalia-generated colors and themes for the compositor and applications.
- Noctalia config, data, cache and state directories.

All removed or modified user files are backed up under
`$HOME/noctalia-backup-20261107`.

### Package removal

The shell package itself still needs to be removed by the user:

```bash
sudo pacman -R noctalia-shell
sudo pacman -D --asexplicit noctalia-qs
```

Use plain `-R` rather than `-Rns`, because `noctalia-qs` must remain installed
for Phantom. Marking it explicit prevents orphan cleanup from removing it.

### Session verification

- Phantom starts from the Hyprland configuration with
  `qs -p $HOME/Workspace/phantom-shell --daemonize`.
- Only one Quickshell instance runs.
- Phantom owns the status notifier watcher and tray.
- No Noctalia process or layer surfaces remain.
- Hyprland reports no configuration errors.

### Rollback

The backup can restore the removed user files, and reinstalling
`noctalia-shell` plus restoring the startup and keybinding changes would bring
Noctalia back. That path is no longer the supported configuration; Phantom is
the only session shell.

---

# 7. First implementation task

Start with **Milestone 0 and Milestone 1 only**.

Do not implement the launcher, control center, notification daemon or other future modules yet.

The first deliverable should include:

1. A working Quickshell project.
2. A modular status bar.
3. Left, center and right sections.
4. Date/time display.
5. Working calendar popup.
6. Dynamic Hyprland workspace indicators.
7. Click-to-switch workspaces.
8. SUPER + 1 through SUPER + 9 shortcuts.
9. System tray for background application applets.
10. Notification, network, Bluetooth, audio and power buttons.
11. Basic popup infrastructure for future modules.
12. Documentation of installed packages and testing.

The right-side controls can initially use functional placeholders only where their full integrations are scheduled for later milestones. Do not present a placeholder as a working system control.

**Important:** Complete and validate the first milestone before proceeding to the next one. Do not generate the entire desktop shell in one large implementation pass.
