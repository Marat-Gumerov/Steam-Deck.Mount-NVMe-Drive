# Steam-Deck.Mount-nvmes 3.7

A supplemental automount script for auto mounting addtional nvme drives on Steam OS machines.

Script to Auto-Mount NTFS, BTRFS & exFat Additional NVMe Drives on systems running SteamOS with more than one nvme.

This script **supplements** Valve's built-in automount functionality for external drives by adding support for additional NVMe drives (nvme1n1-nvme9n1) that Valve's system doesn't handle. For external USB drives and SD cards, Valve's built-in system now handles ext4 drives natively.

NTFS & BTRFS Partitions containing a SteamLibrary at root level or in a folder named `SteamLibrary` will automatically be added to Steam, exFAT isn't supported as a SteamLibrary but will be Mounted for use with other Launchers or for Media/ROMs etc.

# "This is cool! How can I thank you?"
### Why not drop me a sub over on my youtube channel ;) [Chinballs Gaming](https://www.youtube.com/chinballsTV?sub_confirmation=1)

### Also [Check out all these other things I'm making](https://github.com/scawp/Steam-Deck.Tools-List)

# Steam OS 3.5+ Now supports Ext4 external Drives out the box!

This script now **supplements** rather than **overrides** Valve's built-in automount system. It only handles internal NVMe partitions that Valve's system doesn't cover, making it perfect for Steam Machines running Steam OS with multiple nvmes.

# How does this work?

This script supplements Valve's own Auto-Mount system (which lives on SteamOS at `/usr/lib/hwsupport/steamos-automount.sh`) by adding support for `ntfs`, `btrfs` & `exFAT` filesystems on internal NVMe partitions that Valve's system doesn't handle.

Valve's built-in system already handles:
- External USB drives (`sd*` devices) - ext4 format
- SD cards (`mmcblk*` devices) - ext4 format

This script adds support for:
- Additional NVMe drives (`nvme1n1-nvme9n1`) - useful for external NVMe drives or additional internal drives
- Additional filesystem types (NTFS, BTRFS, exFAT) on these drives

SteamOS's rule for external drives lives at `/usr/lib/udev/rules.d/99-steamos-automount.rules`. Rather than overriding this, we add a supplemental rule at `/etc/udev/rules.d/100-steamos-automount-supplement.rules` that runs after Valve's rules and only handles devices that Valve's system doesn't cover.

Looking for the old code? see https://github.com/scawp/Steam-Deck.Mount-External-Drive/tree/pre-3.5

a `udev` rule is added to `/etc/udev/rules.d/100-steamos-automount-supplement.rules` which runs after Valve's built-in `/usr/lib/udev/rules.d/99-steamos-automount.rules`
this then calls systemd `/etc/systemd/system/external-drive-mount@[nvme1n1-nvme9n1].service`
that then runs `/home/deck/.local/share/scawp/SDMED/automount.sh` to Auto Mount any supported Additional NVMe Drives.

`/etc/fstab` is not required for mounting in this way, (however if a Device has an `fstab` entry these scripts will still work)

# Video Guide

https://www.youtube.com/watch?v=Yglf1EKBv2A

# Operation

The Drive(s) will be Auto-Mounted to `/run/media/deck/[LABEL]` eg `/run/media/deck/External-ssd/` if the Device has no `label` then the Devices `UUID` will be used eg `/run/media/deck/a12332-12bf-a33ab-eef/`

# Installation

## Via Curl (One Line Install)

In Konsole type `curl -sSL https://raw.githubusercontent.com/scawp/Steam-Deck.Mount-External-Drive/main/curl_install.sh | bash`

a `sudo` password is required (run `passwd` if required first)

# Uninstall

`sudo rm /etc/udev/rules.d/100-steamos-automount-supplement.rules`

`sudo rm /etc/systemd/system/external-drive-mount@.service`

`sudo rm -r /home/deck/.local/share/scawp/SDMED`

`sudo udevadm control --reload`

`sudo systemctl daemon-reload`

Note: This will only remove the supplemental additional NVMe drive mounting. Valve's built-in external drive mounting will continue to work normally.

# WORK IN PROGRESS!

This will probably have bugs, so beware! log bugs under [issues](https://github.com/scawp/Steam-Deck.Mount-External-Drive/issues)!
