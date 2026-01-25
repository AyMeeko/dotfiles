# KMonad Setup Guide

This document outlines the complete setup process for configuring KMonad to run automatically on startup using systemd user services.

## Prerequisites

- Arch Linux with systemd user services enabled
- KMonad installed (`/usr/bin/kmonad`)
- User account with `input` group membership
- Existing KMonad configuration file (`kmonad.kbd`)

## Step 1: Verify Installation and Permissions

1. **Check KMonad installation:**
   ```bash
   which kmonad
   kmonad --version
   ```

2. **Verify user groups:**
   ```bash
   groups
   # Should include 'input' group
   ```

3. **Check input device path:**
   ```bash
   ls -la /dev/input/by-path/platform-i8042-serio-0-event-kbd
   ```

## Step 2: Create Systemd User Service

1. **Create service file at `~/.config/systemd/user/kmonad.service`:**
   ```ini
   [Unit]
   Description=KMonad keyboard remapper
   After=graphical-session.target

   [Service]
   Type=simple
   ExecStart=/usr/bin/kmonad /home/aymeeko/src/dotfiles/kmonad/kmonad.kbd
   Restart=on-failure
   RestartSec=5
   Environment=LD_LIBRARY_PATH=/run/current-system/sw/lib

   [Install]
   WantedBy=graphical-session.target
   ```

2. **Enable and start the service:**
   ```bash
   systemctl --user daemon-reload
   systemctl --user enable kmonad.service
   systemctl --user start kmonad.service
   ```

## Step 3: Resolve UInput Permissions Issue

The service initially failed with `/dev/uinput: permission denied` errors.

### 3.1 Create Udev Rule

1. **Create udev rule for persistent uinput permissions:**
   ```bash
   echo 'KERNEL=="uinput", GROUP="input", MODE="0660"' | sudo tee /etc/udev/rules.d/99-uinput.rules
   ```

2. **Reload udev rules:**
   ```bash
   sudo udevadm control --reload-rules
   sudo udevadm trigger
   ```

### 3.2 Load UInput Kernel Module

1. **Load the uinput module manually:**
   ```bash
   sudo modprobe uinput
   ```

2. **Verify module is loaded:**
   ```bash
   lsmod | grep uinput
   ```

## Step 4: Make Configuration Permanent

### 4.1 Ensure Module Loads on Boot

1. **Create module-load configuration:**
   ```bash
   echo "uinput" | sudo tee /etc/modules-load.d/uinput.conf
   ```

### 4.2 Verify Udev Rule Persistence

1. **Check the udev rule is correctly placed:**
   ```bash
   ls -la /etc/udev/rules.d/99-uinput.rules
   cat /etc/udev/rules.d/99-uinput.rules
   ```

### 4.3 Verify Service is Enabled

1. **Check service status:**
   ```bash
   systemctl --user is-enabled kmonad.service
   systemctl --user status kmonad.service
   ```

## Step 5: Test and Validate

### 5.1 Immediate Testing

1. **Restart the service after udev fixes:**
   ```bash
   systemctl --user restart kmonad.service
   ```

2. **Check service logs:**
   ```bash
   journalctl --user -u kmonad.service --no-pager -n 10
   ```

3. **Verify device permissions:**
   ```bash
   ls -la /dev/uinput
   # Should show: crw-rw---- 1 root input
   ```

### 5.2 Validate Keyboard Remapping

Test the KMonad configuration by checking that:
- Caps Lock acts as Control+Escape (from `@cesc` alias in config)
- Right Alt is set as compose key
- Normal keyboard functions work correctly

### 5.3 Test Automatic Startup

1. **Reboot or log out/in**
2. **Verify service starts automatically:**
   ```bash
   systemctl --user status kmonad.service
   ```

## Troubleshooting

### Common Issues

1. **Permission denied on /dev/uinput:**
   - Ensure user is in `input` group
   - Check udev rule exists and is correct
   - Verify uinput module is loaded

2. **Service fails to start:**
   - Check journal logs: `journalctl --user -u kmonad.service`
   - Verify config file path is correct
   - Ensure input device path exists

3. **Keyboard remapping not working:**
   - Verify service is running without errors
   - Check KMonad configuration syntax
   - Test with simpler config first

### Useful Commands

```bash
# Check service status
systemctl --user status kmonad.service

# View service logs
journalctl --user -u kmonad.service --follow

# Restart service
systemctl --user restart kmonad.service

# Check device permissions
ls -la /dev/uinput

# Verify uinput module
lsmod | grep uinput

# Test KMonad manually
kmonad /path/to/config.kbd
```

## Configuration Files

- **Service**: `~/.config/systemd/user/kmonad.service`
- **Udev rule**: `/etc/udev/rules.d/99-uinput.rules`
- **Module config**: `/etc/modules-load.d/uinput.conf`
- **KMonad config**: `~/src/dotfiles/kmonad/kmonad.kbd`

## Final Result

KMonad now:
- Starts automatically when you log in
- Restarts automatically if it crashes
- Has proper permissions for uinput device
- Integrates cleanly with your systemd user session
- Provides persistent keyboard remapping functionality

The setup is robust and will survive reboots and system updates.