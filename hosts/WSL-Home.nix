{ inputs, config, ... }:
let
  hostname = "WSL-Home";
  username = "bjorn";
  scheme = let
    themeEnv = builtins.getEnv "NIX_THEME";
  in if themeEnv != "" then config.flake.customSchemes.${themeEnv}
     else config.flake.customSchemes.everforest;
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
