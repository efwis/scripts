#!/bin/bash

set -e

EFI_PART="/dev/nvme0n1p1"
ROOT_PART="/dev/nvme0n1p2"
EFI_MOUNT="/boot/efi"
UKI_PATH="${EFI_MOUNT}/EFI/Linux/arch-linux.efi"


# 1. Ensure EFI partition is mounted
echo "[*] Mounting EFI partition..."
mkdir -p $EFI_MOUNT
mount $EFI_PART $EFI_MOUNT

mkdir -p "$(dirname "$UKI_PATH")"

# 2. Create a dracut config for UKI
echo "[*] Creating dracut UKI config..."
cat <<EOF > /etc/dracut.conf.d/uki.conf
uefi=yes
kernel_cmdline="root=${ROOT_PART} rw"
compress=zstd
show_modules=yes
EOF

# 3. Build Unified Kernel Image
echo "[*] Building UKI..."
dracut --force --no-hostonly-cmdline --kernel-image /boot/vmlinuz-linux $UKI_PATH

# 4. Create a UEFI boot entry
echo "[*] Creating UEFI boot entry..."
efibootmgr --create \
  --disk /dev/nvme0n1 \
  --part 1 \
  --label "EndeavourOS (UKI)" \
  --loader '\EFI\Linux\vmlinuz.efi'

# 5. Create pacman hook to rebuild UKI on kernel update
echo "[*] Setting up pacman hook for UKI rebuild..."
mkdir -p /etc/pacman.d/hooks

cat <<EOF > /etc/pacman.d/hooks/90-uki.hook
[Trigger]
Type = Path
Target = usr/lib/modules/*/vmlinuz
Target = usr/lib/firmware/amd-ucode/microcode_amd*.bin
Operation = Install
Operation = Upgrade

[Action]
Description = Rebuilding Unified Kernel Image (UKI)...
When = PostTransaction
Exec = /usr/bin/dracut --force --uefi --kernel-image /boot/vmlinuz-linux $UKI_PATH
EOF

echo "[✓] EFISTUB UKI setup complete. Reboot to test!"
