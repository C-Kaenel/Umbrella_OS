#!/bin/sh
set -e
echo "Building Umbrella OS..."

cd rootfs
sudo find . | sudo cpio -o -H newc | gzip > /tmp/initrd.img
cd ..

sudo cp /tmp/initrd.img iso/boot/initrd.img
sudo grub-mkrescue -o umbrella-os.iso iso/

echo "Done: umbrella-os.iso"
