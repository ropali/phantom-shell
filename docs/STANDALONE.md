# Phantom — identity and standalone roadmap

Phantom is the name of this shell. It currently lives at
`$HOME/Workspace/phantom-shell`, outside the dotfiles repository but still
developed alongside the Hyprland configuration. The target is a standalone,
installable project with its own repository, release cycle and packaging.

This document records the naming decisions and the extraction plan so that new
work does not add permanent dependencies on the dotfiles layout or on Noctalia.

## Naming

| Item | Value |
|---|---|
| Project name | Phantom |
| Repository name (target) | `phantom` (or `phantom-shell`) |
| Runtime command (target) | `phantom` launcher, backed by Quickshell |
| Current runtime command | `qs -p $HOME/Workspace/phantom-shell` |
| Layer namespaces | `phantom-bar`, `phantom-wallpaper`, `phantom-click-catcher`, `phantom-wifi-password` |
| Compositor color file | `hyprland/.config/hypr/phantom-colors.lua` |
| QML entry point | `shell.qml` |

Namespaces already use the `phantom-*` prefix. The directory name and launch
command will change during extraction.

## Current layout

```text
$HOME/Workspace/phantom-shell/   source during development
$HOME/dotfiles/hyprland/         Hyprland config, autostart and layer rules
```

The Hyprland autostart currently uses:

```lua
hl.exec_cmd("qs -p $HOME/Workspace/phantom-shell --daemonize")
```

This path is temporary and must be updated when Phantom moves to its own
repository/install location.

## Target standalone layout

```text
phantom/
├── shell.qml
├── config/
├── themes/
├── services/
├── modules/
├── components/
├── docs/
├── scripts/
├── VERSION
├── CHANGELOG.md
├── LICENSE
├── README.md
└── PKGBUILD (or packaging/)
```

User files should follow XDG conventions:

- Configuration: `$XDG_CONFIG_HOME/phantom` (usually `$HOME/.config/phantom`)
- Data: `$XDG_DATA_HOME/phantom`
- State: `$XDG_STATE_HOME/phantom`
- Themes: bundled under the install prefix; user themes under
  `$XDG_CONFIG_HOME/phantom/themes/custom`

Use Quickshell's path helpers (`Quickshell.shellDir`, `Quickshell.statePath`,
`Quickshell.configPath`, `Quickshell.env("HOME")`) rather than hardcoded paths.

## Extraction checklist

1. Initialize a git repository in `$HOME/Workspace/phantom-shell`. The folder is
   already outside the dotfiles repository; decide whether to preserve the old
   history with `git filter-repo`.
2. Optionally rename the checkout from `phantom-shell` to `phantom` to match the
   target repository name.
3. Add an install/launcher strategy:
   - source checkout: `qs -p <checkout>`
   - installed: a small `phantom` wrapper that runs Quickshell with the
     installed shell path.
4. Update the Hyprland autostart to the new path.
5. Update the Hyprland layer rule to match `^phantom-bar$` (already done) and
   move `phantom-colors.lua` into the Phantom installation or a documented
   optional Hyprland snippet.
6. Move user themes to the XDG config location and keep the bundled palettes
   read-only.
7. Add packaging for Arch/CachyOS (PKGBUILD) and document exact runtime
   dependencies (`quickshell`/`noctalia-qs` status, Qt modules, NetworkManager,
   PipeWire, BlueZ, Hyprland).
8. Add `VERSION`, `CHANGELOG.md`, a license, and release tags.
9. Add CI for JSON theme validation and QML syntax/load checks.
10. The Noctalia shell has been removed. Keep `noctalia-qs` only as the
    Quickshell runtime until Phantom can switch to a standalone Quickshell
    package.

## Decoupling rules

- Never read or write Noctalia's generated files at runtime.
  `phantom-colors.lua` is now a static file owned by the Phantom setup.
- Do not depend on the dotfiles symlink layout. Use `$HOME`/XDG paths and
  Quickshell path helpers.
- Keep compositor integration through Hyprland IPC; keep the compositor config
  limited to autostart, layer rules and optional color hooks.
- Keep themes, services, components and modules independent of the repository
  location.
- When a path or namespace changes, update this document and `docs/SESSION.md`.

## Versioning

Use semantic versioning once the project is installable. Until then, the shell
is pre-release (`0.x`). Status bar, theming and session integration form the
first public milestone.
