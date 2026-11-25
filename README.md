# Umbrella OS

A small, privacy-oriented Linux system built from scratch with the Linux kernel, BusyBox, GRUB and mkinitcpio. It is not based on any existing distribution.

This is mainly a personal project for my own use. It is experimental, incomplete and not meant as a replacement for an established distribution.

**Status:** Alpha. Boots into a shell with networking on real hardware and in QEMU/KVM.

---

## What works

| Feature | Status |
|---|---|
| Boot into a BusyBox shell (busybox init as PID 1) | Done |
| Network via DHCP, interface detected automatically | Done |
| Random MAC address on every boot | Done |
| Local recursive DNS resolver (Unbound) with DNSSEC | Done |
| Installer (GPT, EFI, ext4, GRUB) | Works, disk detection on real hardware still being tested |
| Kernel hardening | Partly done |
| LUKS disk encryption | Postponed |
| Desktop, browser | Not started |

### Known limitations

- The whole system runs from the initramfs. The installer copies kernel and initramfs to disk, but there is no persistent root filesystem yet, so changes are lost on reboot.
- DNS queries are resolved locally and validated with DNSSEC, but they are not encrypted.
- Only x86_64 with UEFI is supported.

---

## Goals

- No telemetry and as few identifying traits as possible (e.g. MAC randomization)
- DNS handled locally instead of by the ISP
- Keep the system small enough that every part is understood

---

## Building

### Requirements

- Arch Linux host
- Linux kernel 6.12.25 compiled in `build/kernel/linux-6.12.25/`
- BusyBox 1.37.0 compiled in `build/busybox-1.37.0/`
- `grub`, `mkinitcpio`, `parted`, `dosfstools`, `e2fsprogs`, `libisoburn` (for `grub-mkrescue`)

Kernel and BusyBox configs are in `config/`.

### Build

```bash
git clone https://github.com/C-Kaenel/Umbrella_OS.git
cd Umbrella_OS
sudo bash ./scripts/build.sh
```

Note: the build installs the `umbrella` hook to `/etc/initcpio/install/` on the host.

### Test in QEMU

```bash
qemu-system-x86_64 -cdrom umbrella-os.iso -m 512M -netdev user,id=net0 -device e1000,netdev=net0
```

### Install on hardware

Flash the ISO to a USB drive (replace `/dev/sdX`), boot from it and run the installer:

```bash
sudo dd if=umbrella-os.iso of=/dev/sdX bs=4M status=progress conv=fsync
```

```bash
/installer/install.sh
```

The installer erases the selected disk completely.

---

## Project structure

```text
umbrella_os/
├── config/            kernel, BusyBox and mkinitcpio configs
├── installer/
│   └── install.sh     disk installer (runs inside the live system)
├── iso/boot/grub/     GRUB config for the ISO
├── rootfs/            files copied into the initramfs
│   ├── etc/           resolv.conf, Unbound config, root hints, trust anchor
│   └── usr/sbin/      prebuilt unbound, unbound-anchor, cryptsetup
└── scripts/
    ├── build.sh                  builds initramfs and ISO
    ├── mkinitcpio-hook-umbrella  defines what goes into the initramfs
    ├── init                      first process, mounts /proc, /sys, /dev
    ├── inittab                   busybox init config
    ├── rcS                       boot script: MAC randomization, DHCP, Unbound
    ├── udhcpc.script             applies DHCP leases
    └── profile, shell            login environment
```

---

## Next steps

- Persistent root filesystem for installed systems
- Finish installer testing on real hardware (NVMe, USB boot)
- LUKS encryption
- Encrypted DNS

---

## License

MIT License, see [LICENSE](LICENSE).

---

## Disclaimer

This project is experimental. Use it at your own risk and not on machines with data you care about. Parts of the documentation may be written with AI assistance. The system itself is developed with minimized AI usage.
