#!/bin/bash
#Steam Deck External NVMe Mount Uninstaller
#License: DBAD: https://github.com/bcomnes/Steam-Deck.Mount-External-Drive/blob/supplemental/LICENSE.md
#Source: https://github.com/bcomnes/Steam-Deck.Mount-External-Drive/tree/supplemental
# Use at own Risk!

#curl -sSL https://raw.githubusercontent.com/bcomnes/Steam-Deck.Mount-External-Drive/supplemental/curl_uninstall.sh | bash

#stop running script if anything returns an error (non-zero exit )
set -e

rules_install_dir="/etc/udev/rules.d"
service_install_dir="/etc/systemd/system"
script_install_dir="/home/deck/.local/share/scawp/SDMED"
atomic_config_dir="/etc/atomic-update.conf.d"

device_name="$(uname --nodename)"
user="$(id -u deck)"

if [ "$device_name" != "steamdeck" ] || [ "$user" != "1000" ]; then
  zenity --question --width=400 \
  --text="This code has been written specifically for the Steam Deck with user Deck \
  \nIt appears you are running on a different system/non-standard configuration. \
  \nAre you sure you want to continue?"
  if [ "$?" != 0 ]; then
    #NOTE: This code will never be reached due to "set -e", the system will already exit for us but just incase keep this
    echo "bye then! xxx"
    exit 1;
  fi
fi

function uninstall_automount () {
  zenity --question --width=400 \
    --text="This will remove the External NVMe Auto-Mount Service from your system. \
  \nValve's built-in external drive mounting will continue to work normally. \
  \nDo you want to proceed with uninstallation?"
  if [ "$?" != 0 ]; then
    #NOTE: This code will never be reached due to "set -e", the system will already exit for us but just incase keep this
    echo "bye then! xxx"
    exit 0;
  fi

  echo "Removing udev rules..."
  if [ -f "$rules_install_dir/100-steamos-automount-supplement.rules" ]; then
    sudo rm "$rules_install_dir/100-steamos-automount-supplement.rules"
    echo "Removed $rules_install_dir/100-steamos-automount-supplement.rules"
  else
    echo "udev rules file not found, skipping..."
  fi

  echo "Removing systemd service..."
  if [ -f "$service_install_dir/external-drive-mount@.service" ]; then
    sudo rm "$service_install_dir/external-drive-mount@.service"
    echo "Removed $service_install_dir/external-drive-mount@.service"
  else
    echo "systemd service file not found, skipping..."
  fi

  echo "Removing atomic update configuration..."
  if [ -f "$atomic_config_dir/external-drive-mount.conf" ]; then
    sudo rm "$atomic_config_dir/external-drive-mount.conf"
    echo "Removed $atomic_config_dir/external-drive-mount.conf"
  else
    echo "atomic update config file not found, skipping..."
  fi

  echo "Removing script directory..."
  if [ -d "$script_install_dir" ]; then
    sudo rm -rf "$script_install_dir"
    echo "Removed $script_install_dir"
  else
    echo "Script directory not found, skipping..."
  fi

  echo "Reloading Services"
  sudo udevadm control --reload
  sudo systemctl daemon-reload

  echo "Uninstallation complete!"
  echo "Note: This only removed the supplemental NVMe drive mounting."
  echo "Valve's built-in external drive mounting continues to work normally."
}

uninstall_automount

echo "Uninstallation completed successfully!"

zenity --info --width=400 \
  --text="External NVMe Auto-Mount Service has been successfully removed. \
\nValve's built-in external drive mounting continues to work normally."
