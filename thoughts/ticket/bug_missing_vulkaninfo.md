---
type: bug
priority: medium
created: 2026-08-02
status: open
stage: implemented
tags: [gaming, lutris, vulkan]
---

# BUG: vulkaninfo not found in Lutris

## Description

Lutris logs `[ERROR] ['/usr/bin/vulkaninfo', '--summary'] command failed: [Errno 2] No such file or directory`. Additionally, Lutris trash operations fail because `gvfs` (providing GLib trash support) is missing.

## Scope

### In Scope
- Add `pkgs.vulkan-tools` to Lutris gaming module (provides `vulkaninfo`)
- Add `pkgs.gvfs` to Lutris gaming module (enables GLib trash operations)

### Out of Scope
- Itch.io app ID error (Lutris API bug — user workflow fix needed)
- .desktop shortcut errors (Lutris internal bug)
- Game-specific installer failures
- Runtime updates disabled warning (expected on NixOS)

## Implementation

- `modules/features/gaming/lutris.nix`: Added `pkgs.vulkan-tools` and `pkgs.gvfs` to `environment.systemPackages`

## Success Criteria

- [ ] `which vulkaninfo` returns a path after rebuild
- [ ] Lutris startup logs no longer show the vulkaninfo error
- [ ] Lutris trash/delete operations work via GLib trash API
- [ ] `nix flake check` passes on all hosts
