# AGENTS.md

NixOS WSL configuration using the Dendritic Pattern. This is a configuration repo — no build, test, lint, or CI exists.

## Key facts

- **Hosts**: `WSL-IC` (work, with devops/llm), `WSL-Home` (personal, minimal)
- **Username**: `bjorn`
- **Rebuild alias**: `rebuild` (defined in `features/shell/zsh.nix`, runs `sudo nixos-rebuild switch --flake /home/nixos#${hostname}`)

## Project structure (current)

```
flake.nix                        # Entry point — auto-imports modules/ and hosts/ via import-tree
modules/
  system/                        # Infrastructure modules
    flake.nix                    # Declares configurations.nixos option + flake outputs
    home.nix                     # home-manager integration
    nixos-wsl.nix                # WSL enable, defaultUser, docker-desktop, nix-ld
    ssh.nix                      # SSH agent + Azure DevOps / GitHub client config
  features/                      # Feature modules (each exports under flake.modules.nixos.<name>)
    git.nix                      # git delta lazygit
    devops.nix                   # k9s kubectl kubelogin-oidc
    llm.nix                      # claude-code, opencode, mcp-nixos + numtide cache
    nixmate.nix                  # nixmate tool
    lazyvim-home.nix             # LazyVim home-manager module
    shell/                       # MULTIPLE FILES targeting flake.modules.nixos.shell (they merge!)
      zsh.nix                    # zsh, starship, zoxide, oh-my-zsh, aliases, functions
      tmux.nix                   # tmux + plugins
      tools.nix                  # just ranger bat htop gtop glow
      devenv.nix                 # devenv + cachix substituter
hosts/
  WSL-IC.nix                     # Work WSL — imports nix shell git llm devops ssh nixmate + home
  WSL-Home.nix                   # Home WSL — imports nix wsl shell git llm ssh nixmate + home
```

## Dendritic Pattern rules

- Every `.nix` file except `flake.nix` is a **flake-parts module** (`{ inputs, lib, config, ... }:`).
- All modules are auto-imported via `import-tree` — no manual import list.
- NixOS modules live as `deferredModule` values under `config.flake.modules.nixos.*`.
- Home-manager modules live under `config.flake.modules.homeManager.*`.
- The module name is the **filename without extension** (e.g., `git.nix` → `nixos.git`).
- Per-host values are declared as `let` bindings in host files and passed via `_module.args { inherit username hostname; }`. Do NOT use `specialArgs`.

## Home Assistant (NixOS-Server)

- **Module**: `modules/features/server/homeassistant.nix` — targets `flake.modules.nixos.server`, imported by `NixOS-Server`
- **Runtime dir**: `/var/lib/hass/` — `configuration.yaml`, `.storage/`, `zigbee.db`, `custom_components/`, `www/community/`, automations/scripts/scenes YAMLs
- **Service**: `systemctl status|stop|start home-assistant`, logs at `journalctl -u home-assistant` + `/var/lib/hass/home-assistant.log`
- **Port**: 8123 (firewall opened by `openFirewall = true`)

### Nix config is authoritative

On every service start, the preStart script copies `configuration.yaml` from `/nix/store` to `/var/lib/hass/`, overwriting manual edits. To inject directives that can't be expressed in Nix attrs (like `!include`), append them via `systemd.services.home-assistant.preStart = lib.mkAfter`. This runs after the copy.

### Custom component strategy

Custom integrations (HACS, Nordpool, MASS) are **runtime-managed** — not declared in `services.home-assistant.customComponents`. The backup migration copies them as real directories into `/var/lib/hass/custom_components/`. The preStart only removes `/nix/store` symlinks, not real dirs. Nix `customComponents = []` avoids collisions.

### Extra Python packages

Some custom components need pip packages (e.g., Nordpool needs `backoff`, `nordpool`). Add them to `services.home-assistant.extraPackages`:

```nix
extraPackages = python3Packages: with python3Packages; [ backoff ];
```

Check availability with `nix eval nixpkgs#python3Packages.<name>`.

### Zigbee (ZHA)

- The `hass` user must be in the `dialout` group for USB serial access
- Coordinator path: `/dev/serial/by-id/usb-ITEAD_SONOFF_Zigbee_3.0_USB_Dongle_Plus_*`
- ZHA network data lives in `zigbee.db` — copy from backup to preserve paired devices

### Service debugging quick-ref

```bash
journalctl -u home-assistant --no-pager -n 100          # systemd log
tail -100 /var/lib/hass/home-assistant.log                # HA internal log
grep -i error /var/lib/hass/home-assistant.log | tail -30 # errors only
systemctl cat home-assistant                             # service definition
nix eval .#nixosConfigurations.NixOS-Server.config.systemd.services.home-assistant.preStart --raw  # check preStart
```

### Common failures

| Symptom | Cause | Fix |
|---|---|---|
| `cannot overwrite directory` | Nix HACS symlink colliding with runtime HACS dir | Remove Nix `customComponents` HACS derivation |
| `exec format error` / Python import fail | Custom component pip deps missing | Add to `extraPackages` |
| ZHA won't start | `hass` user lacks USB access | `users.users.hass.extraGroups = [ "dialout" ]` |
| Automations/scripts/scenes missing | `configuration.yaml` overwritten without `!include` | Use `lib.mkAfter` in preStart to inject includes |

## Gotchas

- **Shell module is split across multiple files** in `features/shell/`. They all target `flake.modules.nixos.shell` and get merged. Add shell-related config to an existing file there, or create a new one targeting the same key.
- **llm-agents packages** come from `inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}`, not from `pkgs`.
- **`programs.nix-ld.enable = true`** is set for binary compatibility (pre-compiled binaries like .NET tools).
- **`nixpkgs.config.allowUnfree = true`** is set in `llm.nix` for claude-code.
- Remote builders or cloud-only features won't work inside WSL.
- **README.md is stale** — don't trust its module table. Trust the file tree above.

## Adding a new module

1. Create `modules/features/<name>.nix`:
```nix
{ ... }:
{
  flake.modules.nixos.<name> = { pkgs, ... }: {
    # NixOS options here
  };
}
```
For home-manager modules, use `flake.modules.homeManager.<name>` instead.

2. Import it in the host file(s) under `hosts/`.

3. Run `rebuild`.

## Commands

```bash
rebuild                     # Apply configuration (sudo nixos-rebuild switch)
nix flake update            # Update all inputs
nix flake update nixpkgs    # Update a single input
nix flake check             # Check flake outputs (only verification available)
```
