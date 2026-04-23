#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
KERNEL="$ROOT_DIR/build/kernel/linux-6.12.25/arch/x86/boot/bzImage"
ISO_DIR="$ROOT_DIR/iso"
CONFIG_DIR="$ROOT_DIR/config"
OUTPUT_ISO="$ROOT_DIR/umbrella-os.iso"

echo "==> Copying kernel..."
cp "$KERNEL" "$ISO_DIR/boot/vmlinuz"

echo "==> Copying GRUB files to ISO..."
mkdir -p "$ISO_DIR/grub-files/usr/lib/grub"
mkdir -p "$ISO_DIR/grub-files/usr/share/grub"
cp -a /usr/lib/grub/x86_64-efi "$ISO_DIR/grub-files/usr/lib/grub/"
cp -a /usr/share/grub/* "$ISO_DIR/grub-files/usr/share/grub/" 2>/dev/null || true

echo "==> Building initramfs with mkinitcpio..."
sudo mkinitcpio -c "$CONFIG_DIR/mkinitcpio.conf" -g "$ISO_DIR/boot/initramfs.img"

echo "==> Building ISO with grub-mkrescue..."
grub-mkrescue -o "$OUTPUT_ISO" "$ISO_DIR"

echo "==> Done: $OUTPUT_ISO"
