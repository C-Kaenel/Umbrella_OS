# Contributing to Umbrella OS

Umbrella OS is an open project and contributions are welcome. This document explains how to contribute effectively.

---

## Before You Start

Umbrella OS is a security and privacy-focused project. Every contribution must align with the core philosophy:

- Privacy by default – no opt-in required from the user
- Minimal footprint – no unnecessary code, dependencies, or binaries
- Transparency – every protection mechanism must be auditable and toggleable
- No external dependencies that cannot be verified

---

## How to Contribute

### Reporting Bugs

Open an issue on [GitHub Issues](https://github.com/C-Kaenel/Umbrella_OS/issues) and include:

- A clear description of the problem
- Steps to reproduce
- Expected vs actual behavior
- Hardware or QEMU version if relevant

### Reporting Security Vulnerabilities

Do not open a public issue for security vulnerabilities.
Follow the process described in [SECURITY.md](SECURITY.md).

### Submitting Changes

1. Fork the repository
2. Create a branch for your change
3. Make your changes – one logical change per commit
4. Test in QEMU before submitting
5. Test on real hardware if the change affects hardware behavior
6. Open a pull request with a clear description of what and why

---

## Code Standards

- Shell scripts must be POSIX-compatible where possible
- Use `#!/bin/sh` unless Bash-specific features are explicitly required
- No unnecessary comments in code – explain in the pull request or commit message instead
- Every line of code must be understood and intentionally placed
- No external tools or binaries without justification

---

## Commit Messages

Use the format: `scope: short description`

Examples:
```text
rcS: add MAC randomization on every boot
installer: replace udevadm with partition polling loop
docs: add CONTRIBUTING.md
```

Keep commit messages in English.

---

## Testing

All changes must be tested in QEMU before opening a pull request:

```bash
sudo bash ./scripts/build.sh
qemu-system-x86_64 -cdrom umbrella-os.iso -m 512M -netdev user,id=net0 -device e1000,netdev=net0
```

Changes that affect installation or hardware behavior must additionally be tested on real hardware.

---

## Scope

If you are unsure whether a contribution fits the project, open an issue first and describe your idea before implementing it.
