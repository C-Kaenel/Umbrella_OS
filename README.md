# Umbrella OS

Umbrella OS is a privacy-focused Linux distribution designed to block tracking and de-anonymization vectors by default, without requiring manual configuration.

## Status

Work in progress. The system currently boots into a BusyBox shell on real hardware and QEMU/KVM. This project is in a very early stage.

## Disclaimer

This project is experimental.
Parts of the documentation (such as this README) may be written with the help of AI due to limited writing experience. The system itself is being developed with minimized AI usage.

## Goals

- Block hardware identifiers (CPU serial, MAC address, TPM)
- Enforce encrypted DNS (DoH/DoT)
- Normalize browser fingerprints
- Provide self-hosted VPN access
- Ensure zero telemetry by default

## Boot Support

Tested on:
- x86_64 laptops and desktops
- QEMU/KVM virtual machines
- Old hardware (via Minimal boot entry)

## Project Structure

```plaintext
Umbrella_OS/
├── iso/
│   └── boot/
│       ├── bzImage         # Compiled Linux kernel (not in repo)
│       ├── initrd.img      # Generated initrd (not in repo)
│       └── grub/
│           └── grub.cfg    # GRUB bootloader config
├── rootfs/
│   ├── bin/                # BusyBox symlinks (not in repo)
│   ├── dev/                # Device nodes (not in repo)
│   ├── etc/                # Config files
│   ├── proc/               # Mount point
│   ├── sys/                # Mount point
│   ├── tmp/                # Temporary files
│   ├── root/               # Root home directory
│   └── init                # Init script (entry point)
├── build.sh                # Build script
├── .gitignore
├── LICENSE
└── README.md
```

## Build Instructions

### Requirements
- `grub` with `grub-mkrescue`
- `cpio`, `gzip`
- A compiled `bzImage` kernel placed at `iso/boot/bzImage`
- BusyBox binary placed at `rootfs/bin/busybox`

### Quick build
```bash
sudo ./build.sh
```

### Manual steps

**1. Build the initrd:**
```bash
cd rootfs
sudo find . | sudo cpio -o -H newc | gzip > /tmp/initrd.img
```

**2. Copy initrd to ISO directory:**
```bash
sudo cp /tmp/initrd.img ../iso/boot/initrd.img
```

**3. Build the ISO:**
```bash
sudo grub-mkrescue -o ../umbrella-os.iso ../iso/
```

**4. Flash to USB:**
```bash
sudo dd if=../umbrella-os.iso of=/dev/sdX bs=4M status=progress && sync
```
Replace `/dev/sdX` with your USB device (check with `lsblk`).

## License

MIT License
