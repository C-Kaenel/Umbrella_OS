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
