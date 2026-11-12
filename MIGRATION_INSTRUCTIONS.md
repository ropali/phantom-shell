# Quick Migration Instructions

## What We've Done So Far

✅ **Backups Created:**
- `~/.local/state/noctalia-qs.backup` - Phantom state files
- `~/.cache/noctalia-qs.backup` - Cache files  
- `~/.config/hypr/hyprland.lua.backup` - Hyprland config
- Current shell stopped

✅ **Scripts Created:**
- `migrate-to-quickshell.sh` - Complete migration script
- `rollback-quickshell.sh` - Rollback if issues occur

## What You Need to Do

### Run the Migration Script

Open a terminal and run:

```bash
cd ~/Workspace/phantom-shell
./migrate-to-quickshell.sh
```

This will:
1. ✅ Remove noctalia-shell and noctalia-qs
2. ✅ Install upstream quickshell 0.3.2
3. ✅ Migrate state files (theme, wallpaper, settings)
4. ✅ Update Hyprland config (qs → quickshell)
5. ✅ Start Phantom with new runtime
6. ✅ Verify everything works

**The script will ask for your sudo password** to install/remove packages.

## After Migration

### Test Everything

- [ ] Status bar appears
- [ ] Control center opens (click sliders icon)
- [ ] Wi-Fi controls work
- [ ] Bluetooth controls work
- [ ] Audio controls work
- [ ] Media player displays
- [ ] Theme switching works
- [ ] Wallpaper selection works

### Check for Errors

```bash
# Check if running
quickshell list -p $HOME/Workspace/phantom-shell

# Check logs
quickshell log -p $HOME/Workspace/phantom-shell

# Check Wayland layers
hyprctl layers
```

### Verify No More Qt Warning

The warning should be GONE:
```bash
quickshell --version
# Should show: quickshell 0.3.2 (no Qt version warning)
```

## If Something Goes Wrong

### Rollback to noctalia-qs

If you encounter issues:

```bash
cd ~/Workspace/phantom-shell
./rollback-quickshell.sh
```

This will restore everything to the previous state.

### Common Issues

**Issue: "quickshell: command not found"**
```bash
sudo pacman -S quickshell
which quickshell
```

**Issue: Shell doesn't start**
```bash
# Check logs
quickshell log -p $HOME/Workspace/phantom-shell

# Try running without daemon to see errors
quickshell -p $HOME/Workspace/phantom-shell
```

**Issue: QML errors**
```bash
# Check if all modules exist
ls -la /usr/lib/qt6/qml/Quickshell/
```

**Issue: State not preserved**
- This is OK - you can reselect theme from control center
- Wallpaper can be reselected
- Bar layout will reset but can be reconfigured

## Clean Up After Success

Once everything works and you've tested across a reboot:

```bash
# Remove backups
rm -rf ~/.local/state/noctalia-qs.backup
rm -rf ~/.cache/noctalia-qs.backup
rm ~/.config/hypr/hyprland.lua.backup

# Remove old noctalia state (no longer needed)
rm -rf ~/.local/state/noctalia-qs
rm -rf ~/.cache/noctalia-qs

# Remove migration scripts
rm ~/Workspace/phantom-shell/migrate-to-quickshell.sh
rm ~/Workspace/phantom-shell/rollback-quickshell.sh
rm ~/Workspace/phantom-shell/MIGRATION_INSTRUCTIONS.md
```

## Expected Benefits

After migration:
- ✅ No more "Qt 6.11.2 vs 6.12.0" warning
- ✅ Newer Quickshell version (0.3.2 vs 0.0.12)
- ✅ Better maintained upstream project
- ✅ Same functionality, cleaner system

## Command Reference Changes

| Old Command | New Command |
|-------------|-------------|
| `qs -p <path> --daemonize` | `quickshell -p <path> --daemonize` |
| `qs list` | `quickshell list` |
| `qs log` | `quickshell log` |
| `pkill -x qs` | `pkill -x quickshell` |

## Reboot Testing

After confirming everything works:

```bash
sudo reboot
```

After reboot, verify Phantom auto-starts:
```bash
quickshell list -p $HOME/Workspace/phantom-shell
hyprctl layers
```

---

**Ready to migrate?** Run: `./migrate-to-quickshell.sh`

**Need help?** Check the full guide: `docs/QUICKSHELL_MIGRATION.md`
