#!/bin/bash
set -e

# Paths
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
KERNEL="$ROOT_DIR/build/kernel/linux-6.12.25/arch/x86/boot/bzImage"
ISO_DIR="$ROOT_DIR/iso"
CONFIG_DIR="$ROOT_DIR/config"
OUTPUT_ISO="$ROOT_DIR/umbrella-os.iso"

echo "==> Copying kernel..."
cp "$KERNEL" "$ISO_DIR/boot/vmlinuz"

echo "==> Building initramfs with mkinitcpio..."
sudo mkinitcpio -c "$CONFIG_DIR/mkinitcpio.conf" -g "$ISO_DIR/boot/initramfs.img"

echo "==> Building ISO with grub-mkrescue..."
grub-mkrescue -o "$OUTPUT_ISO" "$ISO_DIR"

echo "==> Done: $OUTPUT_ISO"
