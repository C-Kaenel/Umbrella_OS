#!/bin/sh

LOG=/tmp/install.log
log() { echo "$@" | tee -a "$LOG"; }

cleanup() {
    umount /mnt/boot/efi 2>/dev/null || true
    umount /mnt 2>/dev/null || true
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

printf "Enter target disk (e.g. sda, nvme0n1): "
read DISK
[ -z "$DISK" ] && log "No disk entered. Aborted." && exit 1
[ ! -b "/dev/$DISK" ] && log "/dev/$DISK not found. Aborted." && exit 1

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

# NVMe Partitionen heissen nvme0n1p1, SATA heissen sda1
if echo "$DISK" | grep -q "nvme"; then
    PART1="/dev/${DISK}p1"
    PART2="/dev/${DISK}p2"
else
    PART1="/dev/${DISK}1"
    PART2="/dev/${DISK}2"
fi

log "Waiting for kernel to register partitions..."
wait_for_partition $PART1 || { log "[ERROR] Partition 1 not found"; exit 1; }
wait_for_partition $PART2 || { log "[ERROR] Partition 2 not found"; exit 1; }

log "Formatting partitions..."
mkfs.fat -F32 $PART1
mkfs.ext4 -F $PART2

log "Mounting partitions..."
mount $PART2 /mnt
mkdir -p /mnt/boot/efi
mount $PART1 /mnt/boot/efi

log "Finding boot source..."
mkdir -p /tmp/src
CANDIDATES=$(lsblk -rno NAME,TYPE | awk '$2=="disk" || $2=="part" || $2=="rom" {print "/dev/"$1}')
for dev in $CANDIDATES; do
    [ -b "$dev" ] || continue
    # Zieldisk und alle Partitionen davon ausschliessen
    case "$dev" in
        /dev/${DISK}*) continue ;;
    esac
    mount -t iso9660 "$dev" /tmp/src 2>/dev/null || \
    mount -o ro "$dev" /tmp/src 2>/dev/null || continue
    if [ -f /tmp/src/boot/vmlinuz ] && [ -f /tmp/src/boot/initramfs.img ]; then
        BOOT_SRC=/tmp/src/boot
        log "Boot source found on $dev"
        break
    fi
    umount /tmp/src 2>/dev/null
done

[ -z "$BOOT_SRC" ] && log "[ERROR] Cannot find boot source" && exit 1

log "Copying system files..."
cp -a /bin /mnt/
cp -a /etc /mnt/
cp -a /sbin /mnt/
cp -a /installer /mnt/
cp "$BOOT_SRC/vmlinuz" /mnt/boot/ || { log "[ERROR] Failed to copy vmlinuz"; exit 1; }
cp "$BOOT_SRC/initramfs.img" /mnt/boot/ || { log "[ERROR] Failed to copy initramfs.img"; exit 1; }
mkdir -p /mnt/proc /mnt/sys /mnt/dev /mnt/tmp
umount /tmp/src 2>/dev/null

log "Installing GRUB..."
mkdir -p /mnt/usr/share/locale
grub-install --target=x86_64-efi \
    --efi-directory=/mnt/boot/efi \
    --boot-directory=/mnt/boot \
    --removable /dev/$DISK \
    || { log "[ERROR] GRUB installation failed"; exit 1; }

mkdir -p /mnt/boot/grub
cat > /mnt/boot/grub/grub.cfg << GRUBEOF
set default=0
set timeout=3

menuentry "Umbrella OS" {
    linux /boot/vmlinuz rdinit=/init loglevel=7 random.trust_cpu=on
    initrd /boot/initramfs.img
}
GRUBEOF

log "================================"
log "     Installation complete!     "
log "     Remove ISO and reboot.     "
log "================================"
log "Install log saved to $LOG"
