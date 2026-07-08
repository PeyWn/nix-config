{ inputs, config, ... }:
let
  hostname = "Zephyrus";
  username = "bjorn";
  scheme = let
    themeEnv = builtins.getEnv "NIX_THEME";
  in if themeEnv != "" then config.flake.customSchemes.${themeEnv}
     else config.flake.customSchemes.everforest;
  inherit (config.flake.modules) nixos;
in
{
  configurations.nixos.${hostname}.module = { lib, ... }: {
    _module.args = { inherit username hostname scheme; };
    imports = [
      nixos.nix
      nixos.desktop-core
      nixos.theme
      nixos.niri
      nixos.kde
      nixos.steam
      nixos.shell
      nixos.git
      nixos.llm
      nixos.ssh
      nixos.brave
      nixos.alacritty
      nixos.noctalia
      inputs.nixos-hardware.nixosModules.asus-zephyrus-ga401iv
      ../hardware/Zephyrus-GA401IV.nix
      nixos.home
    ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = hostname;
    networking.networkmanager.enable = true;

    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "nvidia-x11"
      "nvidia-settings"
      "nvidia-persistenced"
    ];

    nixpkgs.hostPlatform = "x86_64-linux";
    system.stateVersion = "25.11";
  };
}
