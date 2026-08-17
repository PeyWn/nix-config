---
ticket: thoughts/ticket/lwjgl-games-support.md
created: 2026-08-03
status: approved
---

# LWJGL Games Support — Implementation Plan

## Overview

Add `jdk17` to Zephyrus system packages so LWJGL/GLFW-based games (Mindustry, etc.) have a Java 17 runtime. OpenGL, sound, and steam-run are already correctly configured — no changes needed for those.

## Findings Summary

- **OpenGL**: Already enabled via nixos-hardware ASUS module + `programs.steam.enable` (`hardware.graphics.enable = true`)
- **Sound**: PipeWire pulse compat layer already covers game audio; `sound.enable` is removed from nixpkgs
- **steam-run**: Already installed system-wide by `programs.steam.enable`; add explicit `environment.systemPackages` entry is redundant
- **JDK**: Not currently in any config; `pkgs.jdk17` is available and appropriate for LWJGL games

## Changes Required

| File | Change |
|------|--------|
| `modules/features/gaming/libraries.nix` | **New file** — add `pkgs.jdk17` to `environment.systemPackages` under `flake.modules.nixos.gaming` |

## Implementation Order

1. [x] Create `modules/features/gaming/libraries.nix` — targeting `flake.modules.nixos.gaming`, adding `pkgs.jdk17` to `environment.systemPackages`

## Verification

- [ ] `nix flake check` (all hosts, at review)
- [ ] `nix eval .#nixosConfigurations.Zephyrus.config.environment.systemPackages` — verify jdk17 in list

## Out of Scope

- `hardware.opengl` / `hardware.graphics` changes (already correct)
- `sound.enable` (removed from nixpkgs, pipewire covers it)
- `steam-run` in `environment.systemPackages` (already present via steam module)
- Flatpak Mindustry install (superseded, update gaming-update ticket separately)
