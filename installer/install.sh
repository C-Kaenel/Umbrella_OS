#!/bin/sh

LOG=/tmp/install.log
log() { echo "$@" | tee -a "$LOG"; }

cleanup() {
    umount /tmp/src 2>/dev/null || true
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

list_disks() {
    for d in /sys/block/*; do
        name=${d##*/}
        case "$name" in
            loop*|ram*|zram*|sr*|dm-*|md*) continue ;;
        esac
        [ "$(cat "$d/size" 2>/dev/null || echo 0)" -gt 2097152 ] || continue
        echo "$name"
    done
}

list_all_block_devices() {
    awk 'NR>2 && $4 !~ /loop/ {print "/dev/"$4}' /proc/partitions
}

clear
echo "================================"
echo "    Umbrella OS Installer       "
echo "================================"
echo ""

echo "Available disks:"
printf "  %-14s %6s  %s\n" NAME SIZE MODEL
for disk in $(list_disks); do
    size=$(cat /sys/block/$disk/size 2>/dev/null || echo "0")
    size_gb=$(( size * 512 / 1024 / 1024 / 1024 ))
    model=$(cat /sys/block/$disk/device/model 2>/dev/null || echo "")
    printf "  %-14s %5sG  %s\n" "$disk" "$size_gb" "$model"
done
echo ""

printf "Enter target disk (e.g. sda, nvme0n1): "
read DISK
DISK=${DISK#/dev/}
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

case "$DISK" in
    *[0-9]) PART1="/dev/${DISK}p1"; PART2="/dev/${DISK}p2" ;;
    *)      PART1="/dev/${DISK}1";  PART2="/dev/${DISK}2" ;;
esac

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
log "Available block devices:"
cat /proc/partitions | tee -a "$LOG"
mkdir -p /tmp/src
for dev in $(list_all_block_devices); do
    [ -b "$dev" ] || continue
    case "$dev" in
        /dev/${DISK}*) continue ;;
    esac
    log "Trying $dev..."
    if mount -t iso9660 -o ro "$dev" /tmp/src 2>/dev/null; then
        log "Mounted iso9660 on $dev"
    elif mount -o ro "$dev" /tmp/src 2>/dev/null; then
        log "Mounted ro on $dev"
    else
        log "Cannot mount $dev"
        continue
    fi
    if [ -f /tmp/src/boot/vmlinuz ] && [ -f /tmp/src/boot/initramfs.img ]; then
        BOOT_SRC=/tmp/src/boot
        log "Boot source found on $dev"
        break
    fi
    log "$dev mounted but no boot files found"
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
