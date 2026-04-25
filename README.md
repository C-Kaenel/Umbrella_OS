# Umbrella OS

A privacy-first Linux distribution that blocks tracking and de-anonymization vectors by default – no manual configuration required. Built to be used as a daily driver.

**Status:** Alpha – boots into a working shell with networking on real hardware and QEMU/KVM.

**Audience:** Umbrella OS is intended for advanced users who are comfortable with Linux, the command line, and understand the security concepts involved.

---

## Table of Contents

- [What is Umbrella OS](#what-is-umbrella-os)
- [Download](#download)
- [Features](#features)
- [Threat Model](#threat-model)
- [Build from Source](#build-from-source)
- [Project Structure](#project-structure)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)

---

## What is Umbrella OS

Umbrella OS is a minimal Linux distribution built from scratch using the Linux kernel, BusyBox, GRUB, and mkinitcpio. It is not based on any existing distribution such as Ubuntu, Debian, or Arch Linux.

The goal is a daily-drivable system where every known tracking and de-anonymization vector is blocked by default – without requiring the user to configure anything manually. Every protection mechanism is individually toggleable.

---

## Download

You do not need to build Umbrella OS yourself. Download the latest ISO and flash it to a USB drive.

Releases will be published on the [Releases](https://github.com/C-Kaenel/Umbrella_OS/releases) page once Alpha stabilizes.

Flash to USB:

```bash
sudo dd if=umbrella-os.iso of=/dev/sdX bs=4M status=progress conv=fsync
```

Replace `/dev/sdX` with your USB drive. Boot from USB and run the installer:

```bash
/installer/install.sh
```

---

## Features

| Feature | Status |
|---|---|
| Boots into BusyBox shell | Done |
| Automatic network via DHCP | Done |
| MAC address randomization on every boot | Done |
| Installer for real hardware (GPT + EFI + ext4) | Done |
| DNS over HTTPS | In Progress |
| LUKS full disk encryption | In Progress |
| Kernel hardening | In Progress |
| Privacy-hardened browser | Planned |
| Self-hosted VPN remote access | Planned |
| Desktop environment | Planned |

---

## Threat Model

Umbrella OS addresses four categories of threats:

**1. Hardware / OS level**
Hardware identifiers such as CPU serial numbers, MAC addresses, and TPM keys are not transmitted to external services. MAC addresses are randomized on every boot. No OS telemetry of any kind is present.

**2. Network / ISP level**
DNS queries are encrypted via DoH/DoT over trusted resolvers. WebRTC is disabled to prevent IP leaks. Optional Tor and VPN integration with leak protection is planned.

**3. Browser level**
The included browser will present a unified, generic fingerprint. Third-party cookies, supercookies, tracking pixels, and cross-site tracking are blocked. Per-service container isolation is planned.

**4. Secure remote access**
A self-hosted VPN tunnel provides remote access. When disabled, no ports are open and no background processes remain running.

---

## Build from Source

### Requirements

- Arch Linux host
- Linux kernel 6.12.25 compiled in `build/kernel/linux-6.12.25/`
- BusyBox 1.37.0 compiled in `build/busybox-1.37.0/`
- `grub`, `mkinitcpio`, `parted`, `dosfstools`, `e2fsprogs` installed on the host

### Build

```bash
git clone https://github.com/C-Kaenel/Umbrella_OS.git
cd Umbrella_OS
sudo bash ./scripts/build.sh
```

### Test in QEMU

```bash
qemu-system-x86_64 -cdrom umbrella-os.iso -m 512M -netdev user,id=net0 -device e1000,netdev=net0
```

---

## Project Structure
```text
umbrella_os/
├── config/
│   ├── busybox.config
│   ├── kernel.config
│   └── mkinitcpio.conf
├── installer/
│   └── install.sh
├── iso/
│   └── boot/
│       └── grub/
│           └── grub.cfg
├── scripts/
│   ├── build.sh
│   ├── init
│   ├── inittab
│   ├── mkinitcpio-hook-umbrella
│   ├── profile
│   ├── rcS
│   ├── shell
│   └── udhcpc.script
├── SECURITY.md
├── CONTRIBUTING.md
├── .gitignore
├── LICENSE
└── README.md
```

---

## Roadmap

- **Alpha** – Bootable system with installer
- **Alpha 4** – Script hardening, MAC randomization, reduced ISO size
- **Beta** – DNS over HTTPS, LUKS full disk encryption, kernel hardening
- **1.0** – Desktop environment, privacy-hardened browser, full daily driver

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.
Security vulnerabilities must be reported privately – see [SECURITY.md](SECURITY.md).

---

## License

MIT License – see [LICENSE](LICENSE) for details.

---

## Disclaimer

This project is experimental and under active development. It is not yet suitable for use as a primary system. Parts of the documentation may be written with AI assistance. The system itself is developed with minimized AI usage.
