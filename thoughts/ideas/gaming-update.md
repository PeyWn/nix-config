# Gaming Module Extension — Zephyrus Host

## Objective

Extend the Zephyrus host's `nixos.gaming` module (auto-imported from `modules/features/gaming/*.nix`) with retro/emulation gaming support: gamepad-friendly Lutris UI, RetroArch + emulator cores, ROM library management, and a standalone factory-building game.

---

## Files Added (in `stash@{0}`)

| File | Purpose |
|---|---|
| `modules/features/gaming/lutris-gamepad-ui.nix` | Gamepad-friendly Lutris UI via AppImage |
| `modules/features/gaming/emulators.nix` | RetroArch + cores, Dolphin emu |
| `modules/features/gaming/romm.nix` | RomM ROM library manager via podman |

### Stash also includes

| File | Description |
|---|---|
| `hosts/Zephyrus/default.nix` | Pre-existing bluetooth change (`enable = true; powerOnBoot = false`) — unrelated, commit separately |

---

## Module Details

### `lutris-gamepad-ui.nix`

Wraps the official AppImage from `github.com/andrew-ld/lutris-gamepad-ui` v0.2.0 via `pkgs.appimageTools.wrapType2`.

- **Source**: `lutris-gamepad-ui-x64.AppImage`
- **Sha256**: `b5f8df70cc15efd9be070ac77c10b0dec6d0433489055a5784da5baad6deff6f`
- **Binary**: `lutris-gamepad-ui`
- **`meta.mainProgram`** set for `nix run` support

### `emulators.nix`

RetroArch with hand-picked cores, plus a standalone emulator.

- **retroarch.withCores**:
  - `mgba` — Game Boy / Game Boy Color / Game Boy Advance
  - `melonds` — Nintendo DS
  - `mupen64plus` — Nintendo 64
- **dolphin-emu** (standalone) — Nintendo Wii / GameCube

Mindustry was removed because the nixpkgs build is broken for our revision — the jnigen native link step fails with `ld.bfd: cannot find crti.o` (gcc wrapper `-B` flags not reaching the link invocation). Install manually.

### `romm.nix`

RomM ([rommapp.com](https://rommapp.com)) deployed as podman containers, mirroring the Home Assistant pattern used elsewhere in this repo.

#### Containers

| Container | Image | Port | Volumes |
|---|---|---|---|
| `romm-db` | `mariadb:latest` | — | `romm-db-data:/var/lib/mysql` |
| `romm-redis` | `redis:latest` | — | `romm-redis-data:/data` |
| `romm` | `ghcr.io/rommapp/romm:latest` | `8080:8080` | `/var/lib/romm/library`, `/var/lib/romm/assets`, `/var/lib/romm/config`, `romm-resources` |

- All `autoStart = true`
- `romm` depends on `romm-db` and `romm-redis`
- Environment variables: DB_HOST, DB_NAME, DB_USER, ROMM_DB_DRIVER, REDIS_HOST, HASHEOUS_API_ENABLED
- Secrets via `environmentFiles = [ "/var/lib/romm/romm.env" ]`
- Firewall TCP port 8080 opened
- Desktop entry `romm.desktop` opens `http://localhost:8080` via `xdg-open`

---

## What's Left

### 1. Apply the stash

```bash
git stash pop
```

### 2. Rebuild and verify

```bash
rebuild
```

Then verify:
- [ ] `lutris-gamepad-ui` in PATH
- [ ] `retroarch` in PATH
- [ ] `dolphin-emu` in PATH
- [ ] `romm.desktop` in app menu

### 3. Create RomM secrets file (on Zephyrus host)

Create `/var/lib/romm/romm.env`:

```env
MARIADB_ROOT_PASSWORD=<generate>
MARIADB_PASSWORD=<generate>
DB_PASSWD=<same as MARIADB_PASSWORD>
ROMM_AUTH_SECRET_KEY=<generate with openssl rand -hex 32>
```

Optional for metadata fetching:
```env
IGDB_CLIENT_ID=<twitch app client id>
IGDB_CLIENT_SECRET=<twitch app secret>
SCREENSCRAPER_USER=<username>
SCREENSCRAPER_PASSWORD=<password>
```

### 4. Start containers and place ROMs

After env file created and rebuild applied:
```bash
podman ps  # should show 3 running containers
curl localhost:8080  # should respond
```

Place ROMs in `/var/lib/romm/library/<platform>/roms/` (RomM's expected directory structure).

### 5. Diagnose Lutris — Pokemon Reborn

Lutris can't see `~/Games/` and the Pokemon Reborn install. Needs investigation (not started).

### 6. Install Mindustry manually

Options:
- `nix profile install nixpkgs#mindustry` (if/when upstream build is fixed)
- Flatpak: `flatpak install flathub com.anuke.mindustry`
- Direct JAR from GitHub releases

---

## Architecture Notes

- All three `.nix` files target `flake.modules.nixos.gaming` — they merge automatically with the existing `lutris.nix` and `steam.nix` modules.
- The Zephyrus host imports `nixos.gaming` at `hosts/Zephyrus/default.nix:22` — no changes needed there.
- `nix flake check` passes, and the toplevel built successfully prior to stashing.
