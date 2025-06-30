#!/bin/bash

set -e

# ----------- CONFIG -----------

DEVICE="/dev/nvme0n1p2"  # Replace with your actual root Btrfs partition (e.g. /dev/nvme0n1p2)
MOUNT_POINT="/"    # Assuming this script is run on the live system (not from chroot)
SUBVOL_SNAPSHOTS="@.snapshots"
SNAPPER_CONFIG="root"

# ----------- INSTALL PACKAGES -----------

echo "[1/8] Installing snapper, grub-btrfs, inotify-tools..."
yay -S --noconfirm snapper grub-btrfs inotify-tools

# ----------- CREATE SNAPPER CONFIG -----------

if [ ! -f "/etc/snapper/configs/${SNAPPER_CONFIG}" ]; then
    echo "[2/8] Creating Snapper config for root..."
    sudo snapper -c $SNAPPER_CONFIG create-config /
else
    echo "[2/8] Snapper config already exists. Skipping."
fi

# ----------- MOUNT .snapshots IF NEEDED -----------

if ! mountpoint -q /.snapshots; then
    echo "[3/8] Mounting /.snapshots subvolume..."
    sudo mkdir -p /.snapshots
    sudo mount -o subvol=${SUBVOL_SNAPSHOTS} ${DEVICE} /.snapshots
else
    echo "[3/8] /.snapshots is already mounted."
fi

# ----------- INITIAL SNAPSHOT TEST -----------

echo "[4/8] Creating initial snapshot..."
sudo snapper -c root create -d "Initial snapshot for GRUB test"

# ----------- GENERATE GRUB SNAPSHOT ENTRIES -----------

echo "[5/8] Generating GRUB snapshot menu entries..."
sudo grub-btrfs.generate

echo "[6/8] Updating GRUB config..."
sudo grub-mkconfig -o /boot/grub/grub.cfg

# ----------- ENABLE SYSTEMD WATCHER -----------

echo "[7/8] Enabling grub-btrfs.path for automatic GRUB snapshot updates..."
sudo systemctl enable --now grub-btrfs.path

# ----------- VERIFY -----------

echo "[8/8] Verifying snapshot boot entries..."
if ls /boot/grub/btrfs/* &>/dev/null; then
    echo "✅ Bootable snapshot entries generated successfully."
else
    echo "⚠️ No GRUB snapshot entries found. Check your Snapper config or snapshot mount."
fi

echo "🎉 Setup complete! Reboot and look for 'Snapshots' menu in GRUB."
