# Migrating from noctalia-qs to Upstream Quickshell

## Why Migrate?

**Current situation:**
- Using: `noctalia-qs 0.0.12` (fork, built August 2026)
- Warning: Built against Qt 6.11.2, system has Qt 6.12.0
- Status: Outdated, maintenance unclear

**Upstream Quickshell:**
- Version: `0.3.2` (much newer)
- Built: October 2026 (2 months more recent)
- Repository: Official Arch `extra` + CachyOS repos
- Actively maintained upstream project
- No Qt version warnings (built against current Qt)

## Benefits of Migration

1. ✅ **No more Qt version warnings** - Built against current Qt 6.12.0
2. ✅ **Newer version** - 0.3.2 vs 0.0.12 (likely bug fixes and features)
3. ✅ **Better maintenance** - Upstream project vs abandoned fork
4. ✅ **Official packages** - In Arch `extra` and CachyOS repos
5. ✅ **Same functionality** - All QML modules Phantom needs
6. ✅ **Cleaner system** - Remove Noctalia remnants completely

## Pre-Migration Checklist

### 1. Verify Current Setup
```bash
# Current Quickshell version
qs --version
# Should show: noctalia-qs 0.0.12

# What depends on noctalia-qs
pactree -r noctalia-qs
# Should show: only noctalia-shell

# Current shell status
qs list -p $HOME/Workspace/phantom-shell
```

### 2. Backup Current State
```bash
# Backup Phantom state files
cp -r ~/.local/state/noctalia-qs ~/.local/state/noctalia-qs.backup
cp -r ~/.cache/noctalia-qs ~/.cache/noctalia-qs.backup

# Backup Hyprland config that starts Phantom
cp ~/.config/hypr/hyprland.lua ~/.config/hypr/hyprland.lua.backup
```

### 3. Document Current Functionality
Before migrating, test that everything works:
- [ ] Status bar appears
- [ ] Control center opens
- [ ] Wi-Fi controls work
- [ ] Bluetooth controls work  
- [ ] Audio controls work
- [ ] Media player displays
- [ ] Theme switching works
- [ ] Wallpaper selection works

## Migration Steps

### Step 1: Stop the Current Shell
```bash
pkill -x qs
```

### Step 2: Remove noctalia Packages
```bash
# Remove both noctalia packages
sudo pacman -Rns noctalia-shell noctalia-qs

# Verify removal
pacman -Q | grep noctalia
# Should return nothing
```

### Step 3: Install Upstream Quickshell
```bash
# Install from official repos
sudo pacman -S quickshell

# Verify installation
quickshell --version
# Should show: quickshell 0.3.2

# Verify the command is available
which quickshell
# Should show: /usr/bin/quickshell
```

### Step 4: Update Hyprland Configuration

The upstream package uses `quickshell` command instead of `qs`. Update your Hyprland startup:

**Edit:** `~/.config/hypr/hyprland.lua`

**Change from:**
```lua
hl.exec_cmd("qs -p $HOME/Workspace/phantom-shell --daemonize")
```

**Change to:**
```lua
hl.exec_cmd("quickshell -p $HOME/Workspace/phantom-shell --daemonize")
```

### Step 5: Update State Directory

Quickshell uses different state paths. You have two options:

#### Option A: Fresh Start (Recommended)
Let Phantom create new state files. Your themes and settings will be preserved in the config files.

```bash
# Nothing to do - upstream uses ~/.local/state/quickshell
```

#### Option B: Migrate State Files
Copy your existing state to the new location:

```bash
# Create new state directory
mkdir -p ~/.local/state/quickshell

# Copy state files (theme selection, wallpaper, bar layout)
cp -r ~/.local/state/noctalia-qs/* ~/.local/state/quickshell/

# Do the same for cache
mkdir -p ~/.cache/quickshell
cp -r ~/.cache/noctalia-qs/* ~/.cache/quickshell/
```

### Step 6: Start Phantom with New Runtime
```bash
quickshell -p $HOME/Workspace/phantom-shell --daemonize
```

### Step 7: Verify Everything Works
Check logs:
```bash
quickshell log -p $HOME/Workspace/phantom-shell
```

Test functionality:
- [ ] Status bar appears (check with `hyprctl layers`)
- [ ] Control center opens
- [ ] All system integrations work (Wi-Fi, Bluetooth, Audio)
- [ ] Theme persists or can be reselected
- [ ] No QML errors in logs

### Step 8: Test Across Reboot
```bash
# Reboot to test automatic startup
sudo reboot
```

After reboot, verify:
```bash
quickshell list -p $HOME/Workspace/phantom-shell
# Should show running instance

hyprctl layers
# Should show phantom-bar and phantom-wallpaper
```

## Troubleshooting

### Issue: "Command not found: quickshell"
**Solution:**
```bash
sudo pacman -S quickshell
which quickshell
```

### Issue: Old qs command still exists
**Solution:**
```bash
# Check what provides it
which qs
pacman -Qo $(which qs)

# If it's from noctalia-qs remnants
sudo pacman -Rns noctalia-qs
```

### Issue: QML module not found errors
**Solution:**
Check if upstream Quickshell has all needed modules:
```bash
# List Quickshell QML modules
ls -la /usr/lib/qt6/qml/Quickshell/
```

If modules are missing, you may need to:
1. Check upstream Quickshell documentation for API changes
2. Report missing functionality to Quickshell project
3. Temporarily stay on noctalia-qs and rebuild it

### Issue: Shell doesn't start after migration
**Solution:**
```bash
# Check logs
quickshell log -p $HOME/Workspace/phantom-shell

# Try running without daemon to see errors
quickshell -p $HOME/Workspace/phantom-shell
```

### Issue: State files not migrated correctly
**Solution:**
```bash
# Remove state and start fresh
rm -rf ~/.local/state/quickshell
rm -rf ~/.cache/quickshell

# Restart shell
quickshell -p $HOME/Workspace/phantom-shell --daemonize
```

Your theme selection will reset to default, but you can reselect it from the control center.

## Rollback Plan

If migration fails, you can rollback:

```bash
# Stop upstream quickshell
pkill -x quickshell

# Remove upstream package
sudo pacman -Rns quickshell

# Reinstall noctalia packages
sudo pacman -S noctalia-qs noctalia-shell

# Restore Hyprland config
cp ~/.config/hypr/hyprland.lua.backup ~/.config/hypr/hyprland.lua

# Restore state if needed
rm -rf ~/.local/state/noctalia-qs
cp -r ~/.local/state/noctalia-qs.backup ~/.local/state/noctalia-qs

# Start with old runtime
qs -p $HOME/Workspace/phantom-shell --daemonize
```

## Post-Migration Cleanup

Once confirmed working:

```bash
# Remove backup files
rm -rf ~/.local/state/noctalia-qs.backup
rm -rf ~/.cache/noctalia-qs.backup
rm ~/.config/hypr/hyprland.lua.backup

# Remove old state directories if not migrated
rm -rf ~/.local/state/noctalia-qs
rm -rf ~/.cache/noctalia-qs

# Remove noctalia backup from earlier migration
rm -rf ~/noctalia-backup-20261107
```

## Command Reference Changes

| Old (noctalia-qs) | New (upstream) |
|-------------------|----------------|
| `qs -p <path> --daemonize` | `quickshell -p <path> --daemonize` |
| `qs list -p <path>` | `quickshell list -p <path>` |
| `qs log -p <path>` | `quickshell log -p <path>` |
| `qs --version` | `quickshell --version` |
| `pkill -x qs` | `pkill -x quickshell` |

## Documentation Updates Needed

After successful migration, update these files:

1. **docs/STANDALONE.md** - Update runtime dependency from noctalia-qs to quickshell
2. **docs/SESSION.md** - Update command references and runtime section
3. **docs/PACKAGES.md** - Change noctalia-qs to quickshell
4. **docs/TESTING.md** - Update all command examples
5. **README.md** - Update installation/requirements section

## Expected Outcome

After migration:
- ✅ No Qt version warning
- ✅ Using upstream, maintained Quickshell 0.3.2
- ✅ All Phantom functionality works identically
- ✅ Cleaner system without Noctalia remnants
- ✅ Better long-term maintainability

## API Compatibility Note

Both `noctalia-qs` and upstream `quickshell` use the same QML module structure:
- `import Quickshell`
- `import Quickshell.Hyprland`
- `import Quickshell.Services.Pipewire`
- `import Quickshell.Services.UPower`
- etc.

Your Phantom QML files should work without modification. The only changes needed are:
1. Command name: `qs` → `quickshell`
2. State path: `~/.local/state/noctalia-qs` → `~/.local/state/quickshell`

---

**Status**: Ready to migrate
**Risk level**: Low (easy rollback available)
**Recommended**: Yes - cleaner, newer, better maintained
