{ inputs, config, ... }:
let
  hostname = "Gaming-PC";
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
      nixos.desktop-core
      nixos.theme
      nixos.niri
      nixos.kde
      nixos.gaming
      nixos.shell
      nixos.git
      nixos.llm
      nixos.ssh
      nixos.brave
      nixos.alacritty
      nixos.noctalia
      ../hardware/Gaming-PC.nix
      nixos.home
    ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = hostname;
    networking.networkmanager.enable = true;

    nixpkgs.hostPlatform = "x86_64-linux";
    system.stateVersion = "25.11";
  };
}
