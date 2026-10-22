# AGENTS.md

NixOS configuration using the Dendritic Pattern. This is a configuration repo — no build, test, lint, or CI exists.

## Host Configuration

Host-specific info (repo path, username, rebuild capability) lives in `.opencode/HOST.md` (git-untracked, per-machine). Agents read this for all paths and host awareness.

Example:
```yaml
hostname: Zephyrus
username: peywn
repo: /home/peywn/.config/nixos
canRebuild: true
```

## Key facts

- **Hosts**: `Zephyrus` (laptop), `Gaming-PC` (desktop), `WSL-IC` (work), `WSL-Home` (personal), `NixOS-Server` (home server)
- **Rebuild alias**: `rebuild` (defined in `features/shell/zsh.nix`, runs `sudo nixos-rebuild switch --flake <repo>#${hostname}`)

## Project structure

```
flake.nix                        # Entry point — auto-imports modules/ and hosts/ via import-tree
modules/
  system/                        # Infrastructure modules
    flake.nix                    # Declares configurations.nixos option + flake outputs
    home.nix                     # home-manager integration
    nixos-wsl.nix                # WSL enable, defaultUser, docker-desktop, nix-ld
    ssh.nix                      # SSH agent + Azure DevOps / GitHub client config
    user.nix                     # User account creation
  features/                      # Feature modules (each exports under flake.modules.nixos.<name>)
    git.nix                      # git delta lazygit
    devops.nix                   # k9s kubectl kubelogin-oidc
    llm.nix                      # claude-code, opencode2 (OpenCode 2, exposed as `opencode`), mcp-nixos + numtide cache
    nixmate.nix                  # nixmate tool
    shell/                       # MULTIPLE FILES targeting flake.modules.nixos.shell (they merge!)
      zsh.nix                    # zsh, starship, zoxide, oh-my-zsh, aliases, functions
      tmux.nix                   # tmux + plugins
      tools.nix                  # just ranger bat htop gtop glow
      devenv.nix                 # devenv + cachix substituter
    gaming/                      # Gaming modules targeting flake.modules.nixos.gaming
      steam.nix                  # Steam + gamemode + gamescope + mangohud
      lutris.nix                 # Lutris + gamescope session
    desktop/                     # Desktop environment modules
      desktop-core.nix           # Fonts, xdg, pipewire, etc.
      kde.nix                    # KDE Plasma
      niri.nix                   # Niri compositor
    server/
      homeassistant.nix          # Home Assistant with ZHA
      server-power.nix           # Server power management
hosts/
  Zephyrus/                      # ASUS laptop — imports gaming, power, nixos-hardware
  Gaming-PC/                     # Desktop — imports gaming
  WSL-IC/                        # Work WSL — imports devops, llm
  WSL-Home/                      # Personal WSL — minimal
  NixOS-Server/                  # Home server — imports server
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
- **Gaming module is split** across files in `features/gaming/`. They all target `flake.modules.nixos.gaming` and get merged.
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

## Devenv

The repo has a devenv shell with development tools:

- **`devenv.nix`** (root) — adds `nixd` (Nix LSP) and `alejandra` (Nix formatter) as packages
- **`devenv.yaml`** (root) — inputs from `github:cachix/devenv-nixpkgs/rolling`
- **`modules/features/shell/devenv.nix`** — NixOS module that installs `devenv` + cachix substituter

Enter the shell with `devenv shell` or enable direnv with `direnv allow`. nixd provides in-editor diagnostics, completions, and hover info for Nix files.

## OpenCode Workflow

The repo includes an agentic workflow system for NixOS configuration changes. Commands in `.opencode/commands/`, agents in `.opencode/agents/`.

### Quick Start

```
/nix-workflow add rootless docker to WSL-Home
```

The orchestrator manages the full pipeline. If no input given, it asks what to do.

### Workflow Stages

```
created → planned → implemented → reviewed → done
```

| Stage | What happens |
|-------|-------------|
| `created` | Spawn ticket agent — interactive scope definition → `thoughts/ticket/` |
| `planned` | Spawn nix-researcher → findings → orchestrator writes plan with subtasks → user approves → `thoughts/plans/` |
| `implemented` | Model-analyzer recommends models per-subtask (batch approval) → nix-implementer spawned per subtask with assigned model → subtasks tracked [x] in plan |
| `reviewed` | Spawn nix-reviewer — nix flake check ALL hosts, git diff analysis, scope compliance |
| `done` | Present summary, prompt to rebuild |

### Model Routing

The `model-analyzer` agent scores Go+Free models against each subtask's characteristics. All subtask↔model mappings are presented as a batch for one-time user approval. Each subtask then gets a model-specific nix-implementer invocation.

### Scope Enforcement

When something beyond scope is discovered:

1. STOP immediately
2. Present the finding to the user
3. Ask: update scope, note as `## Future Ideas`, or ignore
4. Do NOT proceed without explicit permission

### Commands

| Command | Purpose |
|---------|---------|
| `/nix-workflow` | Full pipeline orchestrator — ticket → plan → implement → review |
| `/ticket` | Create a structured ticket |
| `/commit` | Create conventional commits |
| `/nix-update` | Update flake inputs with safety verification |
| `/ha-logs` | Show Home Assistant logs |

### Agents

| Agent | Purpose | Default Model | Tier |
|-------|---------|---------------|------|
| `nix-researcher` | Coordinates research — spawns codebase, thoughts, and web-search agents | deepseek-v4-flash | Go |
| `nix-implementer` | Implements a single subtask — receives model from orchestrator | per-subtask | Go |
| `nix-debugger` | Debugs NixOS failures — read-only diagnostics | deepseek-v4-pro | Go |
| `nix-reviewer` | Reviews implementation — nix flake check all hosts | deepseek-v4-pro | Go |
| `model-analyzer` | Recommends models per-subtask with cost bias | gpt-5.6-luna | Go |
| `codebase-locator` | Finds files — Nix-aware, knows Dendritic locations | deepseek-v4-flash | Go |
| `codebase-analyzer` | Analyzes implementation — Nix-aware | deepseek-v4-pro | Go |
| `codebase-pattern-finder` | Finds similar implementations — Nix-aware | deepseek-v4-pro | Go |
| `thoughts-locator` | Finds thoughts/ documents | deepseek-v4-pro | Go |
| `thoughts-analyzer` | Extracts insights from thoughts documents | deepseek-v4-pro | Go |
| `web-search-researcher` | Fetches and analyzes web content | gpt-5.6-luna | Go |
| `ha-debugger` | Debugs Home Assistant failures | deepseek-v4-pro | Go |

## Commands

```bash
rebuild                     # Apply configuration (sudo nixos-rebuild switch)
nix flake update            # Update all inputs
nix flake update nixpkgs    # Update a single input
nix flake check             # Check flake outputs (only verification available)
```
