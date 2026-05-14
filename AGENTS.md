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
