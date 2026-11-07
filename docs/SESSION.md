# Session integration

Phantom is the session shell. The Noctalia shell has been removed from the
session and its user files have been removed so it cannot interfere with
Phantom. The `noctalia-shell` package still needs to be uninstalled. The
`noctalia-qs` package remains only because it provides the Quickshell runtime
(`qs`).

## Session startup

`hyprland/.config/hypr/hyprland.lua` starts Phantom at login:

```lua
hl.exec_cmd("qs -p $HOME/Workspace/phantom-shell --daemonize")
```

The compositor layer rule is:

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

The old `noctalia` layer rule and startup command were removed.

## Noctalia removal

Removed from the session configuration:

- The `noctalia` autostart command and layer rule in `hyprland.lua`.
- Noctalia IPC keybindings in `keybindings.lua`. `SUPER + SPACE` now starts
  `hyprlauncher`; the direct `wpctl`, `brightnessctl` and `playerctl` binds
  remain.
- The generated `noctalia/noctalia-colors.lua`. `phantom-colors.lua` is now a
  static, Phantom-owned compositor palette.

Removed from the user's home:

- Noctalia config, data, cache and state directories.
- Noctalia-generated themes and color schemes for GTK, KDE, Qt, Ghostty,
  Alacritty, Kitty, btop, Yazi, Mango, Zed and Zen.
- References to those themes in `gtk.css`, `kdeglobals`, `dolphinrc`,
  `ghostty/config`, `alacritty.toml`, Yazi's `theme.toml`, Mango's
  `config.conf` and the Zen profile CSS.

All removed or modified files are backed up under:

```text
$HOME/noctalia-backup-20261107
```

The `noctalia-shell` package still needs to be removed by the user:

```bash
sudo pacman -R noctalia-shell
sudo pacman -D --asexplicit noctalia-qs
```

Use plain `-R` (not `-Rns`): `noctalia-qs` must stay installed because Phantom
uses it. Marking it explicit prevents orphan cleanup from removing it.

## Start and stop Phantom

```bash
qs -p $HOME/Workspace/phantom-shell --daemonize
pkill -x qs
```

Inspect the running instance:

```bash
qs list -p $HOME/Workspace/phantom-shell
qs log -p $HOME/Workspace/phantom-shell
```

## Quickshell runtime

`noctalia-qs` is a Quickshell fork and provides `/usr/bin/qs` plus the QML
modules Phantom imports. It is not the Noctalia shell. Its state and cache live
under `~/.local/state/noctalia-qs` and `~/.cache/noctalia-qs`; those are Phantom
runtime files and should not be deleted.

## Verified in the live session

- No Noctalia process or layer surfaces remain.
- Phantom is running as the only Quickshell instance.
- Layer surfaces:
  - `phantom-wallpaper` at the background layer.
  - `phantom-bar` at the top layer.
- Phantom owns `org.kde.StatusNotifierWatcher` and
  `org.kde.StatusNotifierHost`, so tray icons populate.
- No notification daemon exists (`org.freedesktop.Notifications` has no owner).
- `hyprctl reload` succeeds and `hyprctl configerrors` is empty.
- `phantom-colors.lua` and the remaining Lua configuration files pass `luac -p`.
