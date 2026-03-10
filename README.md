# Steam Deck NVMe Auto Mount

A supplemental automount script for SteamOS that adds support for additional NVMe drives.

This script **supplements** Valve's built-in automount functionality by adding support for additional NVMe drives (nvme1n1-nvme9n1) that aren't handled by the default system. It's designed to work alongside Valve's existing automount system without interfering with it.

NTFS & BTRFS partitions containing a SteamLibrary at root level or in a folder named `SteamLibrary` will automatically be added to Steam. exFAT drives will be mounted for use with other launchers or for media/ROMs but cannot be used as Steam libraries.

## About This Project

This project is a derivative of the original [Steam-Deck.Mount-External-Drive](https://github.com/scawp/Steam-Deck.Mount-External-Drive) by scawp, modified to work as a supplement to Valve's built-in automount system rather than replacing it and focusing on internal nVME drives only.
This intended use of this was for a SteamMachine build: [bret.io/blog/2025/you-can-just-build-a-steam-machine/](https://bret.io/blog/2025/you-can-just-build-a-steam-machine/)

## SteamOS 3.5+ Built-in Support

SteamOS 3.5+ now includes native support for external drives with ext4 formatting. This script supplements that functionality by:

- Adding support for additional NVMe drives (nvme1n1-nvme9n1)
- Supporting additional filesystem types (NTFS, BTRFS, exFAT)
- Working alongside Valve's system without conflicts

## How It Works

This script supplements Valve's automount system located at `/usr/lib/hwsupport/steamos-automount.sh` by adding support for filesystem types and devices that Valve's system doesn't handle.

**Valve's built-in system handles:**
- External USB drives (`sd*` devices) with ext4 format
- SD cards (`mmcblk*` devices) with ext4 format

**This script adds support for:**
- Additional NVMe drives (`nvme1n1-nvme9n1`) - useful for external NVMe enclosures or additional internal drives
- NTFS, BTRFS, and exFAT filesystem support on these drives

The script uses a udev rule at `/etc/udev/rules.d/100-steamos-automount-supplement.rules` that runs after Valve's built-in rules (`/usr/lib/udev/rules.d/99-steamos-automount.rules`) and only handles devices that Valve's system doesn't cover.

**System components:**
- udev rule: `/etc/udev/rules.d/100-steamos-automount-supplement.rules`
- systemd service: `/etc/systemd/system/external-drive-mount@.service`
- mount script: `/home/deck/.local/share/scawp/SDMED/automount.sh`

No `/etc/fstab` entries are required, though existing fstab entries will continue to work.

## Installation

### One-line Install

You'll need to enter your sudo password (run `passwd` first if you haven't set one).

Open Konsole and run:

```bash
curl -sSL https://raw.githubusercontent.com/Marat-Gumerov/Steam-Deck.Mount-NVMe-Drive/marat/curl_install.sh | bash
```

### Persistence Across Updates

The installer automatically configures your system to preserve the automount functionality across SteamOS updates using the atomic update configuration system.

## Operation

Drives will be auto-mounted to `/run/media/deck/[LABEL]`. For example:
- Labeled drive: `/run/media/deck/External-SSD/`
- Unlabeled drive: `/run/media/deck/a12332-12bf-a33ab-eef/`

## Uninstall

### One-line Uninstall

Open Konsole and run:

```bash
curl -sSL https://raw.githubusercontent.com/Marat-Gumerov/Steam-Deck.Mount-NVMe-Drive/marat/curl_uninstall.sh | bash
```

### Manual Uninstall

Alternatively, you can manually remove the components:

```bash
sudo rm /etc/udev/rules.d/100-steamos-automount-supplement.rules
sudo rm /etc/systemd/system/external-drive-mount@.service
sudo rm /etc/atomic-update.conf.d/external-drive-mount.conf
sudo rm -r /home/deck/.local/share/scawp/SDMED
sudo udevadm control --reload
sudo systemctl daemon-reload
```

Note: This only removes the supplemental NVMe drive mounting. Valve's built-in external drive mounting will continue to work normally.

## Support

If you encounter issues, please report them in the [GitHub Issues](https://github.com/Marat-Gumerov/Steam-Deck.Mount-NVMe-Drive/issues) section.

## License

This project maintains the same DBAD (Don't Be A Dick) license as the original project.
