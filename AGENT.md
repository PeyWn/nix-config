# ADENT.md

NixOS WSL configuration using the Dendritic Pattern.

## Key facts

- **Hostname**: WSL-IC
- **Username**: bjorn
- **Config location**: `/home/nixos/`
- **Rebuild alias**: `rebuild` (runs `sudo nixos-rebuild switch --flake /home/nixos#WSL-IC`)

## Project structure

```
flake.nix                   # Entry point — imports modules/ and hosts/ via import-tree
modules/
  flake-parts.nix           # Enables flake-parts.flakeModules.modules
  nixos.nix                 # Declares configurations.nixos option + flake outputs
  nixos-wsl.nix             # Wires in nixos-wsl module
  shell.nix                 # zsh, starship, zoxide, oh-my-zsh, shell functions
  tmux.nix                  # tmux config and plugins
  git.nix                   # git config, delta pager, lazygit
  ssh.nix                   # SSH agent and client config
  nvim.nix                  # neovim + LazyVim dependencies
  devtools.nix              # ranger and other general tools
  devenv.nix                # devenv + cachix substituter
  claude.nix                # claude-code (unfree)
hosts/
  WSL-IC.nix                # Work WSL machine (username=bjorn)
  WSL-Home.nix              # Personal WSL machine (username=bjorn)
```

## The Dendritic Pattern — rules

- Every `.nix` file except `flake.nix` is a **flake-parts module** (`{ inputs, lib, config, ... }:`).
- All modules are auto-imported via `import-tree` — no manual imports list needed.
- Each file represents a **feature**, not a configuration target.
- NixOS modules live as `deferredModule` values under `config.flake.modules.nixos.*`.
- Per-host values (username, hostname) are declared as `let` bindings in each host file and passed into NixOS modules via `_module.args`. Never use `specialArgs`.

## Adding a new module

1. Create `modules/<feature>.nix`:
```nix
{ ... }:
{
  flake.modules.nixos.<feature> = { pkgs, ... }: {
    # NixOS options here
  };
}
```

2. Add `nixos.<feature>` to the imports list in the relevant host file(s) under `hosts/`.

3. Copy the file to `/home/nixos/modules/` and run `rebuild`.

## Common commands

```bash
rebuild                         # Apply configuration
nix flake update                # Update all inputs
nix flake update nixpkgs        # Update a single input
nix flake check                 # Check all outputs
```

## Notes

- `programs.nix-ld.enable = true` is set — pre-compiled binaries (e.g. .NET tools) work via the compatibility layer.
- `nixpkgs.config.allowUnfree = true` is set in `claude.nix` for claude-code.
- SSH key is at `~/.ssh/id_rsa` (RSA 4096, configured for Azure DevOps).

- The SSH agent starts automatically via `programs.ssh.startAgent = true`.
