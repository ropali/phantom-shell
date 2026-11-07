# Session integration and Noctalia replacement

The custom status bar is now the permanent session shell. Noctalia was removed
from the Hyprland startup command but remains installed as a manual fallback.

## Changes made

### `hyprland/.config/hypr/hyprland.lua`

- Replaced:
  ```lua
  hl.exec_cmd("noctalia")
  ```
  with:
  ```lua
  hl.exec_cmd("qs -p $HOME/Workspace/phantom-shell --daemonize")
  ```
- Added a layer rule so the custom bar receives the same compositor blur
  treatment as the old Noctalia bar:
  ```lua
  hl.layer_rule({
  	name = "phantom",
  	match = { namespace = "^phantom-bar$" },
  	no_anim = true,
  	ignore_alpha = 0.5,
  	blur = true,
  	blur_popups = true,
  })
  ```

### `hyprland/.config/hypr/keybindings.lua`

- Commented out the Noctalia IPC volume and brightness binds. They targeted a
  process that no longer runs at login.
- Left the direct `wpctl`, `brightnessctl`, `playerctl` binds active.
- Left the Noctalia launcher/control-center/settings/annotation/lock binds in
  place for the manual Noctalia fallback.

### `hyprland/.config/hypr/phantom-colors.lua`

Noctalia generated `noctalia/noctalia-colors.lua` and removed it when it stopped.
The final `require("noctalia.noctalia-colors")` therefore failed after the
switch. It was replaced with a static compositor palette:

```lua
require("phantom-colors")
```

The new file holds the same Gruvbox active/inactive/group border colors and is
symlinked from `$HOME/.config/hypr/phantom-colors.lua`.

No other Hyprland configuration was changed.

### Backups

Created before editing:

```text
hyprland/.config/hypr/hyprland.lua.bak-20261106
hyprland/.config/hypr/keybindings.lua.bak-20261106
```

### Temporary wallpaper

Because Noctalia rendered the wallpaper itself, stopping it would leave a blank
desktop. `modules/wallpaper/Wallpaper.qml` renders a static background-layer
surface using `config/Settings.qml -> wallpaperPath`, currently:

```text
$HOME/Pictures/wallpapers/Gruv/stairs.jpg
```

The control center now provides the wallpaper selector; the background layer
renders the selected path.

## Starting and stopping manually

Start the shell (the session command):

```bash
qs -p $HOME/Workspace/phantom-shell --daemonize
```

Stop the shell:

```bash
pkill -x qs
```

Inspect the running instance:

```bash
qs list -p $HOME/Workspace/phantom-shell
qs log -p $HOME/Workspace/phantom-shell
```

## Noctalia manual fallback

Noctalia remains installed. To use it as a fallback, stop Phantom first
so the two do not fight over the tray, wallpaper and exclusive zones:

```bash
pkill -x qs
noctalia --daemon
```

The existing Noctalia IPC keybindings then work again.

## Rollback to Noctalia at login

```bash
cd $HOME/dotfiles/hyprland/.config/hypr
cp hyprland.lua.bak-20261106 hyprland.lua
cp keybindings.lua.bak-20261106 keybindings.lua
pkill -x qs
noctalia --daemon
```

Then log out and back in, or reload the Hyprland configuration.

## Verified in the live session

- Noctalia process stopped; no `noctalia` layer surfaces remain.
- Phantom running (PID 91159 at verification time) (`qs -p ... --daemonize`).
- Layer surfaces:
  - `phantom-wallpaper` at the background layer, 2560x1440.
  - `phantom-bar` at the top layer, `0 4 2560 38`.
- Phantom owns `org.kde.StatusNotifierWatcher` and
  `org.kde.StatusNotifierHost`, so tray icons populate.
- No notification daemon exists (`org.freedesktop.Notifications` has no owner).
- Only one Quickshell instance is running.
- `hyprctl reload` succeeded and `hyprctl configerrors` is empty.
- Compositor border colors resolve to Gruvbox (`ffb8bb26` active, `ff282828`
  inactive) through `phantom-colors.lua`.
- Workspace 3 was briefly activated and returned to workspace 2; the bar updated
  its active workspace both times.
- An empty workspace screenshot matched the configured wallpaper's average
  color, confirming the background layer renders the image.

Startup-at-login could not be verified without a reboot; the command above is
the same one that was tested manually, and the Lua files pass `luac -p`.
