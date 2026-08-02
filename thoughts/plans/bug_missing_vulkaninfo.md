---
ticket: thoughts/ticket/bug_missing_vulkaninfo.md
created: 2026-08-02
status: approved
---

# Fix Lutris vulkan-tools + gvfs — Implementation Plan

## Overview

Two packages missing from Lutris environment: `vulkan-tools` (provides `vulkaninfo`) and `gvfs` (provides GLib trash support). Both added to the gaming module's systemPackages.

## Changes Required

| File | Change |
|------|--------|
| `modules/features/gaming/lutris.nix` | Added `pkgs.vulkan-tools` and `pkgs.gvfs` to `environment.systemPackages` |

## Implementation Order

1. [x] Add `pkgs.vulkan-tools` and `pkgs.gvfs` to lutris.nix:23

## Verification

- [x] `nix eval .#nixosConfigurations.Zephyrus.config.environment.systemPackages` — both packages confirmed
- [ ] `nix flake check` (all hosts)

## Out of Scope

- Itch.io app ID error (user workflow)
- .desktop shortcuts (Lutris bug)
- Game installer failures
