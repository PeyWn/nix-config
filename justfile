# !/usr/bin/env -S just --justfile
[private]
default:
    just --list

rebuild theme:
    zsh -i -c "rebuild -- --theme {{theme}}"

switch-IC theme:
    sudo NIX_THEME="{{theme}}" nixos-rebuild switch --impure --flake ./#WSL-IC

switch-WSL-Home theme:
    sudo NIX_THEME="{{theme}}" nixos-rebuild switch --impure --flake ./#WSL-Home

switch-Server theme:
    sudo NIX_THEME="{{theme}}" nixos-rebuild switch --impure --flake ./#NixOS-Server

update:
    nix flake update

update-input input:
    nix flake update {{input}}

# Check whitespace and evaluate/build the flake without updating flake.lock.
check:
    git diff --check
    git diff --cached --check
    nix flake check --no-write-lock-file

# Enable the tracked pre-commit hook for this clone.
install-hooks:
    chmod +x .githooks/pre-commit
    git config --local core.hooksPath .githooks

gc:
    sudo nix-collect-garbage -d

power:
    @if command -v power >/dev/null 2>&1; then \
        echo "power: Zephyrus power management (cpu profiles + gpu modes)"; \
        echo "usage: power <command>   -- see 'man power' for the full manual"; \
        power help; \
    else \
        echo "power is not installed on this host (Zephyrus only)"; \
    fi
