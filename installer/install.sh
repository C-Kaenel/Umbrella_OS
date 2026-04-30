#!/bin/sh

LOG=/tmp/install.log
log() { echo "$@" | tee -a "$LOG"; }

cleanup() {
    umount /mnt/boot/efi 2>/dev/null || true
    umount /mnt 2>/dev/null || true
    cryptsetup close umbrella_root 2>/dev/null || true
}
trap cleanup EXIT

wait_for_partition() {
    local part="$1"
    local retries=10
    while [ $retries -gt 0 ]; do
        [ -b "$part" ] && return 0
        sleep 1
        retries=$((retries - 1))
    done
    return 1
}

clear
echo "================================"
echo "    Umbrella OS Installer       "
echo "================================"
echo ""

lsblk -d -o NAME,SIZE,MODEL | grep -v loop
echo ""

printf "Enter target disk (e.g. sda): "
read DISK
[ -z "$DISK" ] && log "No disk entered. Aborted." && exit 1
[ ! -b "/dev/$DISK" ] && log "/dev/$DISK not found. Aborted." && exit 1

echo ""
echo "Encryption options:"
echo "  1) Full Disk Encryption (recommended)"
echo "  2) No Encryption"
echo ""
printf "Choose [1-2]: "
read ENCRYPT_CHOICE

echo ""
log "WARNING: All data on /dev/$DISK will be destroyed."
printf "Type YES to continue: "
read CONFIRM
[ "$CONFIRM" != "YES" ] && log "Aborted." && exit 1

log "Partitioning /dev/$DISK..."
parted -s /dev/$DISK mklabel gpt
parted -s /dev/$DISK mkpart primary fat32 1MiB 257MiB
parted -s /dev/$DISK set 1 esp on
parted -s /dev/$DISK mkpart primary ext4 257MiB 100%

log "Waiting for kernel to register partitions..."
wait_for_partition /dev/${DISK}1 || { log "[ERROR] Partition not found"; exit 1; }
wait_for_partition /dev/${DISK}2 || { log "[ERROR] Partition not found"; exit 1; }

log "Formatting EFI partition..."
mkfs.fat -F32 /dev/${DISK}1

if [ "$ENCRYPT_CHOICE" = "1" ]; then
    log "Setting up LUKS encryption on /dev/${DISK}2..."
    echo ""
    echo "You will now set your disk encryption passphrase."
    echo "Remember this passphrase - without it, your data cannot be recovered."
    echo ""
    cryptsetup luksFormat \
        --type luks2 \
        --cipher aes-xts-plain64 \
        --key-size 512 \
        --hash sha512 \
        --pbkdf argon2id \
        /dev/${DISK}2 || { log "[ERROR] LUKS format failed"; exit 1; }

    log "Opening encrypted volume..."
    cryptsetup open /dev/${DISK}2 umbrella_root || { log "[ERROR] Could not open LUKS volume"; exit 1; }

    ROOT_DEV=/dev/mapper/umbrella_root
    CRYPT_DEV=/dev/${DISK}2
else
    ROOT_DEV=/dev/${DISK}2
    CRYPT_DEV=""
fi

log "Formatting root partition..."
mkfs.ext4 -F $ROOT_DEV

log "Mounting partitions..."
mount $ROOT_DEV /mnt
mkdir -p /mnt/boot/efi
mount /dev/${DISK}1 /mnt/boot/efi

log "Copying system files..."
cp -a /bin /mnt/
cp -a /etc /mnt/
cp -a /sbin /mnt/
cp -a /installer /mnt/
cp /boot/vmlinuz /mnt/boot/
cp /boot/initramfs.img /mnt/boot/
mkdir -p /mnt/proc /mnt/sys /mnt/dev /mnt/tmp /mnt/usr/sbin

cp /usr/sbin/cryptsetup /mnt/usr/sbin/ 2>/dev/null || true

log "Installing GRUB..."
mkdir -p /mnt/usr/share/locale
grub-install --target=x86_64-efi \
    --efi-directory=/mnt/boot/efi \
    --boot-directory=/mnt/boot \
    --removable /dev/$DISK \
    || { log "[ERROR] GRUB installation failed"; exit 1; }

mkdir -p /mnt/boot/grub

if [ "$ENCRYPT_CHOICE" = "1" ]; then
    CRYPT_UUID=$(cryptsetup luksUUID /dev/${DISK}2)
    cat > /mnt/boot/grub/grub.cfg << GRUBEOF
set default=0
set timeout=3

menuentry "Umbrella OS" {
    linux /boot/vmlinuz rdinit=/init loglevel=7 random.trust_cpu=on cryptdevice=UUID=${CRYPT_UUID}:umbrella_root root=/dev/mapper/umbrella_root
    initrd /boot/initramfs.img
}
GRUBEOF
else
    cat > /mnt/boot/grub/grub.cfg << GRUBEOF
set default=0
set timeout=3

menuentry "Umbrella OS" {
    linux /boot/vmlinuz rdinit=/init loglevel=7 random.trust_cpu=on
    initrd /boot/initramfs.img
}
GRUBEOF
fi

log "================================"
log "     Installation complete!     "
if [ "$ENCRYPT_CHOICE" = "1" ]; then
log "     Full Disk Encryption ON    "
fi
log "     Remove ISO and reboot.     "
log "================================"
log "Install log saved to $LOG"
