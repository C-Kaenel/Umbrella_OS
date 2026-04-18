# Umbrella OS

Umbrella OS is a privacy-focused Linux distribution built from scratch,
designed to block tracking and de-anonymization vectors by default,
without requiring manual configuration.

## Status

Alpha 1 – The system boots into a BusyBox shell on real hardware and QEMU/KVM.

## Disclaimer

This project is experimental and under active development.
Parts of the documentation may be written with the help of AI due to limited
writing experience. The system itself is being developed with minimized AI usage.

## Goals

- Block hardware identifiers (CPU serial, MAC address, TPM)
- Enforce encrypted DNS (DoH/DoT)
- Normalize browser fingerprints
- Provide self-hosted VPN remote access
- Ensure zero telemetry by default
- Full disk encryption (LUKS)
- Automatic metadata stripping from files

## Components – Alpha 1

- Linux kernel 6.12.25 LTS
- BusyBox 1.37.0 (statically compiled)
- GRUB bootloader
- mkinitcpio initramfs

## Roadmap

- [x] Phase 1 – Minimal bootable system
- [ ] Phase 2 – Installer, partitioning and LUKS encryption
- [ ] Phase 3 – Privacy hardening and configuration layer
- [ ] Phase 4 – Desktop and everyday applications

## Boot Support

Tested on:

- x86_64 laptops and desktops
- QEMU/KVM virtual machines

## Build Instructions

### Requirements

- Arch Linux host system
- Packages: grub, mkinitcpio, qemu
- Pre-compiled kernel in `build/kernel/linux-6.12.25/`
- Pre-compiled BusyBox in `build/busybox-1.37.0/`

### Build ISO

```bash
sudo bash scripts/build.sh
```

### Test in QEMU

```bash
qemu-system-x86_64 -cdrom umbrella-os.iso -m 512M
```

### Flash to USB

```bash
sudo dd if=umbrella-os.iso of=/dev/sdX bs=4M status=progress conv=fsync
```

## License

MIT License

