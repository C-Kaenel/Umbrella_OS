#!/bin/sh
set -e

# Umbrella OS Build Script
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
ISO_OUT="$SCRIPT_DIR/umbrella-os.iso"

echo "================================"
echo "   Umbrella OS Build Script"
echo "================================"

echo "[1/3] Building initrd..."
cd "$SCRIPT_DIR/rootfs"
sudo find . | sudo cpio -o -H newc | gzip > /tmp/initrd.img

echo "[2/3] Copying initrd to ISO directory..."
sudo cp /tmp/initrd.img "$SCRIPT_DIR/iso/boot/initrd.img"

echo "[3/3] Building ISO..."
sudo grub-mkrescue -o "$ISO_OUT" "$SCRIPT_DIR/iso/"

echo ""
echo "Done: $ISO_OUT"
echo "Flash with: sudo dd if=$ISO_OUT of=/dev/sdX bs=4M status=progress && sync"
