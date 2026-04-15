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
- x86_64 laptops
- Desktop systems
- QEMU/KVM virtual machines

## Build Instructions

\`\`\`bash
cd rootfs
sudo find . | cpio -o -H newc | gzip > /tmp/initrd.img
sudo cp /tmp/initrd.img ../iso/boot/initrd.img
sudo grub-mkrescue -o ../umbrella-os.iso ../iso/
\`\`\`

## License

MIT License

## Project Structure
Umbrella_OS/
├── iso/                    # ISO build directory
│   └── boot/
│       ├── bzImage         # Compiled Linux kernel (not in repo)
│       ├── initrd.img      # Generated initrd (not in repo)
│       └── grub/
│           └── grub.cfg    # GRUB bootloader config
├── rootfs/                 # Root filesystem
│   ├── bin/                # BusyBox symlinks (not in repo)
│   ├── dev/                # Device nodes (not in repo)
│   ├── etc/                # Config files
│   ├── proc/               # Kernel process info (mount point)
│   ├── sys/                # Kernel device info (mount point)
│   ├── tmp/                # Temporary files
│   ├── root/               # Root home directory
│   └── init                # Init script (entry point)
├── build.sh                # Build script
├── .gitignore
├── LICENSE
└── README.md
