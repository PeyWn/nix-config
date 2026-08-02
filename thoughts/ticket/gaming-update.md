---
stage: reviewed
status: open
---

# Gaming Module Extension — Zephyrus Host

Extend the Zephyrus host's `nixos.gaming` module with retro/emulation gaming support: gamepad-friendly Lutris UI, RetroArch + emulator cores, and a standalone factory-building game.

## Scope

### 1. Apply Stashed Modules (stash@{0})

Two new modules targeting `flake.modules.nixos.gaming`:

- **`modules/features/gaming/lutris-gamepad-ui.nix`** — wraps `lutris-gamepad-ui-x64.AppImage` v0.2.0 via `pkgs.appimageTools.wrapType2`. Adds `lutris-gamepad-ui` to system packages.
- **`modules/features/gaming/emulators.nix`** — RetroArch with cores (mgba, melonds, mupen64plus) + standalone dolphin-emu. Adds to system packages.

Plus bluetooth change in **`hosts/Zephyrus/default.nix`**: `hardware.bluetooth.enable = true; powerOnBoot = false;`

### 2. Diagnose Lutris — Pokemon Reborn

Investigate: Lutris can't see `~/Games/` and the Pokemon Reborn install.

## Out of Scope

To be determined during planning — currently unknown.

## Future Ideas

- **RomM ROM library manager** — podman containers (mariadb, redis, romm app) with firewall TCP 8080 and `.desktop` entry. Alpha code in `stash@{0}` at `modules/features/gaming/romm.nix`.
- **Flatpak for Mindustry** — `flatpak install flathub com.anuke.mindustry` as an alternative install method. Needs review of whether to add flatpak system-wide to Zephyrus.
