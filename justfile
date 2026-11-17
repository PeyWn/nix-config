# !/usr/bin/env -S just --justfile
[private]
default:
    just --list

# Rebuild the current host, forwarding options to the shell function.
[positional-arguments]
rebuild *args:
    zsh -i -c 'rebuild "$@"' -- "$@"

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

# Collect unused store paths without deleting profile generations.
gc:
    sudo nix-collect-garbage

# Prune old user and system generations, then collect unused store paths.
gc-old age="30d":
    nix-collect-garbage --delete-older-than {{quote(age)}}
    sudo nix-collect-garbage --delete-older-than {{quote(age)}}

# Deduplicate identical store files without deleting generations.
optimise:
    sudo nix-store --optimise

power:
    @if command -v power >/dev/null 2>&1; then \
        echo "power: Zephyrus power management (cpu profiles + gpu modes)"; \
        echo "usage: power <command>   -- see 'man power' for the full manual"; \
        power help; \
    else \
        echo "power is not installed on this host (Zephyrus only)"; \
    fi
