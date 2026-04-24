{ config, ... }:
let
  hostname = "WSL-Home";
  username = "bjorn";
  inherit (config.flake.modules) nixos;
in
{
  configurations.nixos.${hostname}.module = {
    _module.args = { inherit username hostname; };
    imports = [
      nixos.nix
      nixos.wsl
      nixos.shell
      nixos.devtools
      nixos.git
      nixos.devenv
      nixos.claude
      nixos.home
      nixos.lazyvim
      nixos.ssh
      nixos.tmux
    ];
    nixpkgs.hostPlatform = "x86_64-linux";
    networking.hostName = hostname;
    system.stateVersion = "25.11";
  };
}
