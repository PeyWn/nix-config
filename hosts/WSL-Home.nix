{ inputs, config, ... }:
let
  hostname = "WSL-Home";
  username = "bjorn";
  scheme = config.flake.customSchemes.everforest-light;
  inherit (config.flake.modules) nixos;
in
{
  configurations.nixos.${hostname}.module = {
    _module.args = { inherit username hostname scheme; };
    imports = [
      nixos.nix
      nixos.wsl
      nixos.theme
      nixos.shell
      nixos.git
      nixos.llm
      nixos.ssh
      nixos.nixmate
      nixos.home
    ];
    nixpkgs.hostPlatform = "x86_64-linux";
    networking.hostName = hostname;
    system.stateVersion = "25.11";
  };
}
