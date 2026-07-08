# !/usr/bin/env -S just --justfile
[private]
default:
    just --list

rebuild theme:
    zsh -i -c "rebuild -- --theme {{theme}}"

switch-IC theme:
    sudo NIX_THEME="{{theme}}" nixos-rebuild switch --impure --flake /home/nixos#WSL-IC

switch-WSL-Home theme:
    sudo NIX_THEME="{{theme}}" nixos-rebuild switch --impure --flake /home/nixos#WSL-Home

switch-Server theme:
    sudo NIX_THEME="{{theme}}" nixos-rebuild switch --impure --flake /home/nixos#NixOS-Server

update:
    nix flake update

update-input input:
    nix flake update {{input}}

check:
    nix flake check

gc:
    sudo nix-collect-garbage -d
