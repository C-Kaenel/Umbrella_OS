# Contributing

Umbrella OS is mainly a personal project. Issues and suggestions are welcome, but there is no guarantee that pull requests will be merged or answered quickly.

## Bugs

Open an issue on [GitHub Issues](https://github.com/C-Kaenel/Umbrella_OS/issues) with a short description, steps to reproduce, and the hardware or QEMU setup used.

Security issues: see [SECURITY.md](SECURITY.md).

## Changes

- One logical change per commit
- Test in QEMU (see README); changes to the installer or hardware support also on real hardware
- Shell scripts: POSIX `sh` where possible (BusyBox ash is the target shell)

## Commit messages

Format: `scope: short description`, in English.

```text
rcS: add MAC randomization on every boot
installer: replace udevadm with partition polling loop
docs: add CONTRIBUTING.md
```
