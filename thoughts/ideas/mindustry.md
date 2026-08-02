# Mindustry — Standalone Factory-Building Game

## Problem

The nixpkgs build for mindustry is broken (jnigen native link step fails with `ld.bfd: cannot find crti.o`). Need an alternative install method.

## Options

1. **Flatpak** — `flatpak install flathub com.anuke.mindustry`
   - Requires adding flatpak system-wide to Zephyrus (`services.flatpak.enable = true`)
   - Needs review of whether flatpak is wanted on the host

2. **nix profile install** — `nix profile install nixpkgs#mindustry` (if/when upstream build is fixed)

3. **Direct JAR** — download from GitHub releases, run manually

## Status

Unresolved. Needs decision on flatpak vs waiting for nixpkgs fix.
