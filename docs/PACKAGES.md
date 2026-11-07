# Installed packages

No packages were installed for Milestone 0, Milestone 1 or the theming system.
Everything below was already present on the system.

## Required packages

| Package | Reason | Feature | Mandatory |
|---|---|---|---|
| `noctalia-qs` | Provides `/usr/bin/qs` and `/usr/bin/quickshell`, including the Quickshell QML modules and service plugins (Hyprland, PipeWire, Networking, Bluetooth, SystemTray, UPower, Notifications) | Entire shell | Yes |
| `qt6-declarative` | Qt Quick, Qt Quick Layouts and `Qt.labs.folderlistmodel` used by the theme manager | Bar UI, theme discovery | Yes |
| `hyprland` | Compositor and window manager; provides `hyprctl` and the Hyprland IPC | Workspaces, power menu logout | Yes |
| `pipewire` / `wireplumber` | Audio backend exposed through `Quickshell.Services.Pipewire` | Audio button and volume control | Yes for audio |
| `networkmanager` | Network backend exposed through `Quickshell.Networking` | Network status and Wi-Fi controls | Yes for network |
| `bluez` | Bluetooth backend exposed through `Quickshell.Bluetooth` | Bluetooth status and devices | Yes for Bluetooth |
| `systemd` | Provides `loginctl` and `systemctl` | Lock, suspend, reboot, shutdown | Yes |

## Optional / external

| Item | Reason | Feature | Mandatory |
|---|---|---|---|
| Fonts: `JetBrainsMono Nerd Font` | All icon glyphs and text use the Nerd Font family | Bar, popups, control center | Yes for the bundled themes |
| A session locker handling `loginctl lock-session` | The power menu's Lock action emits the standard lock request | Lock screen | No |
| `docs/THEMING.md` external hook command | Optional script for Hyprland borders, GTK/Qt themes, icons or wallpaper | External theme sync | No |

## Session integration notes

- No new package was installed when Noctalia was removed from the Hyprland
  autostart.
- No wallpaper daemon (hyprpaper/swaybg/swww) is installed. The temporary static
  wallpaper is drawn by Quickshell itself, so no package is needed.
- No standalone notification daemon is installed. Desktop notifications are
  unavailable until the native notification module is implemented.

## Notes

- The installed Quickshell build identifies itself as `noctalia-qs 0.0.12`.
  Running it prints:
  `noctalia-qs was built against Qt 6.11.2 but the system has updated to Qt 6.12.0`.
  It loads and runs, but the package should be rebuilt by its maintainer.
- Quickshell's Networking module only enumerates Wi-Fi devices in this build.
  Wired/Ethernet status is read with `nmcli` (already provided by
  NetworkManager); controls still use native Quickshell APIs.
- Icons are rendered from Nerd Font glyphs; no icon-theme package was added.
- Theme persistence uses Quickshell's own state directory, so no extra package is
  needed.
