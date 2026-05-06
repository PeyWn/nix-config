#!/usr/bin/env -S just --justfile
[private]
default:
    just --list

rebuild-WSL-HOME:
    sudo nixos-rebuild switch --flake /home/nixos#WSL-Home

rebuild-IC:
    sudo nixos-rebuild switch --flake /home/nixos#WSL-IC

update:
    nix flake update

update-input input:
    nix flake update {{input}}

check:
    nix flake check

gc:
    sudo nix-collect-garbage -d
