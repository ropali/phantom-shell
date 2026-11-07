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
9. Keep Noctalia available as a fallback throughout development.
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

## Milestone 3: Control center

Create a dedicated quick-settings panel. Though some of these already have their own dedicated buttons so keep them as it is but add those option in here as well.

Features:

- Wi-Fi toggle and network selection.
- Bluetooth toggle and device management.
- Audio volume.
- Audio output selection.
- Audio input selection.
- Brightness.
- Battery status.
- Power profile.
- Night light.
- Do Not Disturb.
- Theme switcher,
- Wallpaper selector

The control center should use the shared system services.

---

## Milestone 4: Notification center

Implement:

- Notification popups.
- Notification history.
- Notification actions.
- Dismiss functionality.
- Do Not Disturb.
- Clear all notifications.
- Notification grouping.

Ensure there is only one active notification daemon.

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

# 6. Migration and rollback strategy

Noctalia must remain available during development.

### Development stage

- Run Quickshell manually.
- Keep Noctalia startup configuration untouched.
- Avoid starting competing notification daemons.
- Test the new status bar independently.

### Integration stage

- Disable only the Noctalia component being replaced.
- Enable the equivalent custom component.
- Verify that no duplicate panels or notification services appear.
- Keep a backup of the original configuration.

### Final migration

Only after the required modules are stable:

- Remove Noctalia from the startup configuration.
- Enable Quickshell at session startup.
- Verify session startup and shutdown.
- Verify suspend/resume.
- Verify monitor hotplugging.
- Retain the ability to launch Noctalia manually as a fallback until satisfied.

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
