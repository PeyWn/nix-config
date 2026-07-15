{ inputs, config, ... }:
let
  hostname = "WSL-IC";
  username = "bjorn";
  scheme = let
    themeEnv = builtins.getEnv "NIX_THEME";
  in if themeEnv != "" then config.flake.customSchemes.${themeEnv}
     else config.flake.customSchemes.everforest-dark;
  inherit (config.flake.modules) nixos;
in
{
  configurations.nixos.${hostname}.module = {
    _module.args = { inherit username hostname scheme; };
    imports = [
      nixos.nix
      nixos.wsl
      nixos.home
      nixos.user
      nixos.theme
      nixos.shell
      nixos.git
      nixos.llm
      nixos.devops
      nixos.ssh
      nixos.nixmate
    ];
    nixpkgs.hostPlatform = "x86_64-linux";
    networking.hostName = hostname;
    system.stateVersion = "25.11";
  };
}
