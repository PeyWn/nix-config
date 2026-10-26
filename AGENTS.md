# AGENTS.md

NixOS configuration for five hosts, using the Dendritic Pattern.

## Hosts

| Host | Machine | Notable modules |
|---|---|---|
| `Zephyrus` | ASUS laptop | niri, KDE, gaming, power |
| `Gaming-PC` | Desktop | niri, KDE, gaming |
| `NixOS-Server` | Home server | KDE, server (Home Assistant) |
| `WSL-IC` | Work WSL | devops |
| `WSL-Home` | Personal WSL | - |

Each host's imports are listed in `hosts/<host>/default.nix`.

## Layout

- `flake.nix` - inputs; auto-imports `modules/` and `hosts/` with import-tree.
- `modules/system/` - infrastructure: the `configurations.nixos` option and flake outputs, WSL, SSH, users.
- `modules/features/` - one feature per file or directory.
- `modules/homemanager/` - home-manager modules.
- `hosts/<host>/` - the host's `default.nix` and `_hardware.nix`.

## Dendritic Pattern rules

- Every `.nix` file except the root `flake.nix` is a flake-parts module, and import-tree loads all of them, so there is no import list.
- import-tree skips paths containing `/_`, which is why a host imports its `_hardware.nix` explicitly.
  It does not skip dot-directories: a stray `.devenv/` under `modules/` breaks any evaluation that is not git-based.
- NixOS modules are `deferredModule` values under `flake.modules.nixos.<name>`, and hosts import them as `nixos.<name>`.
  The name is the key a file sets, not its filename: `system/flake.nix` sets `nixos.nix`, `system/nixos-wsl.nix` sets `nixos.wsl`, and the files in `features/shell/`, `features/gaming/` and `features/server/` each merge into one module named after their directory.
- Home-manager modules set `homeManagerModules.<name>`; `features/home.nix` applies all of them to every host that imports `nixos.home`.
- Per-host values (`username`, `hostname`, `scheme`) are `let` bindings in the host file, passed into modules via `_module.args`.
  Never use `specialArgs`.
- To add a feature, create `modules/features/<name>.nix` setting `flake.modules.nixos.<name>`, then add `nixos.<name>` to the hosts that need it.

## flake.lock

- Run `git pull` before `just update` or `rebuild`.
- A `flake.lock` change goes in its own `[UPDATE] flake.lock` commit.
- `.gitattributes` stops git from merging `flake.lock`.
  On a conflict, keep one side and run `nix flake lock`; never merge it by hand, because a text merge can silently point an input at another repo.
- While investigating, pass `--no-write-lock-file`, or `nix eval` may rewrite and stage the lock.

## Commands

- `just --list` shows the recipes; `just check` (`nix flake check`) is the only verification.
- `rebuild` switches the current host; `rebuild --theme <name>` also selects a scheme from `flake.customSchemes` (default `everforest-dark`).
  The theme comes from `NIX_THEME`, so it only applies to `--impure` evaluations; a pure evaluation always uses the default.
- `devenv.nix` provides `nixd` and `alejandra`.

## Home Assistant (NixOS-Server)

- Defined in `modules/features/server/homeassistant.nix`.
- Home Assistant runs as the podman container `homeassistant` (unit `podman-homeassistant`) on the host network.
- `/var/lib/hass` is mounted as `/config`, so `configuration.yaml`, HACS and integrations are managed inside Home Assistant, not in Nix.
- The Zigbee dongle is passed in with `--device`; Matter runs as the native `matter-server` service on `wlp4s0`.
- The container waits up to 30 seconds for `wlp4s0` to get an IPv4 address before it starts.
- Debug with `systemctl status podman-homeassistant matter-server`, `journalctl -u podman-homeassistant` and `podman logs homeassistant`.

## Gotchas

- `nix-ld` is enabled on the WSL hosts only (`modules/system/nixos-wsl.nix`), for pre-compiled binaries.
- Unfree packages are allowed one by one with `allowUnfreePredicate` (`features/gaming/steam.nix`, `hosts/Zephyrus/default.nix`); there is no global `allowUnfree`.
- `llm-agents` packages come from `inputs.llm-agents.packages.${system}`, not from `pkgs`.
- `README.md` is stale; trust the files.
