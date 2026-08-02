---
stage: created
status: open
---

# LWJGL Games Support — System Requirements

Add NixOS system-level requirements to support LWJGL/GLFW-based games (Mindustry and similar JVM games) launched from a Games directory, replacing the proposed flatpak alternative from the gaming-update ticket.

## Scope

### 1. OpenGL Hardware Acceleration
`hardware.opengl.enable = true;` — required for LWJGL native libraries.

### 2. Sound Compatibility
Ensure ALSA/PulseAudio compatibility for games that use PulseAudio. Current config uses pipewire with pulse compat (`services.pulseaudio.enable = false; services.pipewire.pulse.enable = true;`).

### 3. steam-run + JDK
Add `steam-run` and `jdk17` to `environment.systemPackages`. LWJGL games bundle pre-built native libraries expecting FHS paths (`/usr/lib/libGL.so` etc.). `steam-run` wraps the process in a namespace with `/usr/lib` mounts so dlopen works.

## Out of Scope

- Flatpak-based Mindustry install (covered by `gaming-update` Future Ideas)
- Game-specific launchers — those are managed by the Games-directory Justfile outside this repo
- RetroArch/emulator requirements (already covered by emulators.nix)

## Notes

- If paths change on rebuild, launchers need regeneration (outside-repo concern)
- `sound` module may conflict with existing `pipewire` pulse compat setup — needs research
