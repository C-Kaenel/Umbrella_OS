#!/bin/sh

clear
echo "================================"
echo "    Umbrella OS Installer       "
echo "================================"
echo ""

lsblk -d -o NAME,SIZE,MODEL | grep -v loop
echo ""

printf "Enter target disk (e.g. sda): "
read DISK

echo ""
echo "WARNING: All data on /dev/$DISK will be destroyed."
printf "Type YES to continue: "
read CONFIRM

[ "$CONFIRM" != "YES" ] && echo "Aborted." && exit 1

echo "Partitioning /dev/$DISK..."

parted -s /dev/$DISK mklabel gpt
parted -s /dev/$DISK mkpart primary fat32 1MiB 257MiB
parted -s /dev/$DISK set 1 esp on
parted -s /dev/$DISK mkpart primary ext4 257MiB 100%

echo "Formatting partitions..."

mkfs.fat -F32 /dev/${DISK}1
mkfs.ext4 -F /dev/${DISK}2

echo "Mounting partitions..."

mount /dev/${DISK}2 /mnt
mkdir -p /mnt/boot/efi
mount /dev/${DISK}1 /mnt/boot/efi

echo "Copying system files..."

cp -a /. /mnt/

echo "Installing GRUB..."

grub-install --target=x86_64-efi --efi-directory=/mnt/boot/efi --boot-directory=/mnt/boot --removable /dev/$DISK

grub-mkconfig -o /mnt/boot/grub/grub.cfg

echo "Unmounting..."

umount /mnt/boot/efi
umount /mnt

echo "================================"
echo "     Installation complete!     "
echo "     Remove ISO and reboot.     "
echo "================================"
