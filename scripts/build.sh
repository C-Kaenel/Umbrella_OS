#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
KERNEL="$ROOT_DIR/build/kernel/linux-6.12.25/arch/x86/boot/bzImage"
ISO_DIR="$ROOT_DIR/iso"
CONFIG_DIR="$ROOT_DIR/config"
OUTPUT_ISO="$ROOT_DIR/umbrella-os.iso"

[ -f "$KERNEL" ] || { echo "[ERROR] Kernel not found: $KERNEL"; exit 1; }

echo "==> [$(date +%H:%M:%S)] Cleaning old artifacts..."
rm -f "$ISO_DIR/boot/vmlinuz" "$ISO_DIR/boot/initramfs.img" "$OUTPUT_ISO"

echo "==> [$(date +%H:%M:%S)] Copying kernel..."
cp "$KERNEL" "$ISO_DIR/boot/vmlinuz"

if [ ! -d "$ISO_DIR/grub-files/usr/lib/grub/x86_64-efi" ]; then
    echo "==> [$(date +%H:%M:%S)] Copying GRUB files to ISO..."
    mkdir -p "$ISO_DIR/grub-files/usr/lib/grub"
    mkdir -p "$ISO_DIR/grub-files/usr/share/grub"
    cp -a /usr/lib/grub/x86_64-efi "$ISO_DIR/grub-files/usr/lib/grub/"
    cp -a /usr/share/grub/* "$ISO_DIR/grub-files/usr/share/grub/" 2>/dev/null || true
else
    echo "==> [$(date +%H:%M:%S)] GRUB files already present, skipping..."
fi

echo "==> [$(date +%H:%M:%S)] Installing mkinitcpio hook..."
sed "s|@ROOT_DIR@|$ROOT_DIR|g" "$ROOT_DIR/scripts/mkinitcpio-hook-umbrella" | \
    sudo tee /etc/initcpio/install/umbrella >/dev/null

touch "$ISO_DIR/boot/initramfs.img"
echo "==> [$(date +%H:%M:%S)] Building initramfs with mkinitcpio..."
KVER="$(ls /lib/modules/ | grep lts | tail -1)"
[ -n "$KVER" ] || KVER="$(uname -r)"
sudo mkinitcpio -k "$KVER" -c "$CONFIG_DIR/mkinitcpio.conf" -g "$ISO_DIR/boot/initramfs.img"

echo "==> [$(date +%H:%M:%S)] Building ISO with grub-mkrescue..."
grub-mkrescue -o "$OUTPUT_ISO" "$ISO_DIR"

echo "==> [$(date +%H:%M:%S)] Done: $OUTPUT_ISO"
