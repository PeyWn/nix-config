---
ticket: thoughts/ticket/gaming-update.md
created: 2026-08-02
status: approved
---

# Gaming Module Extension — Implementation Plan

## Overview

Add retro/emulation gaming support and a gamepad-friendly Lutris UI to the `nixos.gaming` module (affects both Zephyrus and Gaming-PC hosts). Enable Bluetooth on Zephyrus. Investigate Lutris/Pokemon Reborn directory visibility issue.

## Findings Summary

- Existing `nixos.gaming` module has two files (`steam.nix`, `lutris.nix`) both targeting `flake.modules.nixos.gaming` with pattern `{ ... }: { flake.modules.nixos.gaming = { pkgs, ... }: { ... }; }` — `modules/features/gaming/lutris.nix:6`, `modules/features/gaming/steam.nix:3`
- Both Zephyrus (`hosts/Zephyrus/default.nix:22`) and Gaming-PC (`hosts/Gaming-PC/default.nix:22`) import `nixos.gaming`
- All new code exists ready in `stash@{0}` — three in-scope files plus one out-of-scope (`romm.nix`)
- No existing `appimageTools`, `retroarch`, `dolphin-emu`, or bluetooth config anywhere in codebase
- Minor formatting in stashed `emulators.nix` — extra blank line inside `let` block (lines 10-11) to clean up
- Working tree is clean aside from the ticket file itself (`thoughts/ticket/gaming-update.md`)

## Changes Required

### New: `modules/features/gaming/emulators.nix`
- Target `flake.modules.nixos.gaming` (merges into existing gaming module)
- RetroArch with cores: mgba (Game Boy), melonds (Nintendo DS), mupen64plus (Nintendo 64)
- Standalone `pkgs.dolphin-emu` (Wii/GameCube)
- Add to `environment.systemPackages`

### New: `modules/features/gaming/lutris-gamepad-ui.nix`
- Target `flake.modules.nixos.gaming` (merges into existing gaming module)
- Wrap `lutris-gamepad-ui-x64.AppImage` v0.2.0 via `pkgs.appimageTools.wrapType2`
- Add to `environment.systemPackages`

### Edit: `hosts/Zephyrus/default.nix`
- Add `hardware.bluetooth.enable = true; powerOnBoot = false;` after `boot.loader` block (line 35)

### Investigation (no code change): Lutris — Pokemon Reborn
- Check why Lutris can't see `~/Games/` and Pokémon Reborn install
- Runtime investigation — check filesystem permissions, Lutris library paths, game directory layout

## Implementation Order

1. Create `modules/features/gaming/emulators.nix` (apply from stash, clean up extra blank line)
2. Create `modules/features/gaming/lutris-gamepad-ui.nix` (apply from stash as-is)
3. Edit `hosts/Zephyrus/default.nix` — add `hardware.bluetooth` block after line 35
4. Diagnose Lutris — Pokémon Reborn directory visibility (manual investigation on Zephyrus host)

## Verification

- [ ] `nix flake check` passes
- [ ] `nix eval .#nixosConfigurations.Zephyrus.config.environment.systemPackages` includes retroarch, dolphin-emu, lutris-gamepad-ui
- [ ] `nix eval .#nixosConfigurations.Gaming-PC.config.environment.systemPackages` includes retroarch, dolphin-emu, lutris-gamepad-ui
- [ ] Bluetooth config present in Zephyrus evaluation
- [ ] Lutris directory investigation findings documented in ticket

## Out of Scope

- **RomM ROM library manager** — `romm.nix` is in the stash but explicitly out of scope (Future Idea). Do NOT apply.
- **Flatpak for Mindustry** — Future Idea, no changes
- **Pokemon Reborn fix** — Only diagnosis; actual fix needs its own ticket if issues found
