# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Supplemental automount script for SteamOS-based devices (e.g. custom Steam Machines) that have multiple NVMe drives. Adds automount support for secondary NVMe drives (nvme1-nvme9) alongside Valve's built-in automount system, which only handles the primary drive. Fork of [scawp/Steam-Deck.Mount-External-Drive](https://github.com/scawp/Steam-Deck.Mount-External-Drive), modified to supplement rather than replace Valve's handling.

**Target**: SteamOS 3.5+ devices with multiple NVMe drives (requires deck user UID 1000)

## Architecture

The system has three layers triggered in sequence:

1. **udev rule** (`lib/100-steamos-automount-supplement.rules`) — matches `nvme[1-9]n1` partitions only, deliberately skips devices Valve handles (sd*, mmcblk0, nvme0n1). Priority 100 ensures it runs after Valve's priority-99 rules.
2. **systemd template service** (`lib/external-drive-mount@.service`) — oneshot service that calls automount.sh with `add`/`remove` actions per device.
3. **automount.sh** — core logic: acquires file lock, queries filesystem via `lsblk`+`jq`, mounts via `udisks2` (`busctl`), creates SteamLibrary folder, registers with Steam via IPC (`steam://` URLs).

### Installation paths

- Script: `/home/deck/.local/share/scawp/SDMED/automount.sh`
- udev rules: `/etc/udev/rules.d/100-steamos-automount-supplement.rules`
- systemd service: `/etc/systemd/system/external-drive-mount@.service`
- Persistence config: `/etc/atomic-update.conf.d/external-drive-mount.conf`

### Reference files

`valve/` directory contains copies of Valve's automount system for comparison — these are never installed.

## Key Design Constraints

- **Supplemental only**: Never override or conflict with Valve's automount. Only handle nvme1-9 devices.
- **Persistence across SteamOS updates**: Uses `/etc/atomic-update.conf.d/` to survive atomic updates.
- **File locking**: `/var/run/jupiter-automount-*.lock` prevents race conditions during concurrent mount events.
- **exFAT limitation**: Mounted but NOT added to Steam (no symlink support).
- **Supported filesystems**: ext4, NTFS, BTRFS, exFAT.

## Installation/Uninstallation

Install and uninstall are done via curl one-liners that use zenity for GUI dialogs:

```bash
# Install
curl -sSL https://raw.githubusercontent.com/Marat-Gumerov/Steam-Deck.Mount-NVMe-Drive/supplemental/curl_install.sh | bash

# Uninstall
curl -sSL https://raw.githubusercontent.com/Marat-Gumerov/Steam-Deck.Mount-NVMe-Drive/supplemental/curl_uninstall.sh | bash
```

The installer downloads from the `supplemental` branch, installs files via sudo, configures persistence, reloads udev/systemd, and prompts for reboot.

## Code Style

- Bash with `set -euo pipefail`
- Uses `jq` for JSON parsing of `lsblk` output
- Uses `busctl` for udisks2 D-Bus communication
- Lock files for concurrency control
- Zenity dialogs for user-facing install/uninstall feedback
