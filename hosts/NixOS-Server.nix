{ inputs, config, ... }:
let
  hostname = "NixOS-Server";
  username = "peywn";
  scheme = config.flake.customSchemes.everforest-light;
  inherit (config.flake.modules) nixos homeManager;
in
{
  configurations.nixos.${hostname}.module = {
    _module.args = { inherit username hostname scheme; };
    imports = [
      nixos.nix
      nixos.desktop
      nixos.theme
      #nixos.niri
      nixos.kde
      nixos.server
      nixos.shell
      nixos.git
      nixos.llm
      nixos.ssh
      nixos.brave
      nixos.alacritty
      nixos.noctalia
      ../hardware/NixOS-Server.nix
      {
        imports = [ nixos.home ];
        home-manager.backupFileExtension = "bak";
        home-manager.extraSpecialArgs = { inherit username hostname scheme; };
        home-manager.users.${username} = {
          imports = [
            homeManager.shell
            homeManager.lazyvim
            homeManager.theme
          ];
          home.stateVersion = "25.11";
        };
      }
    ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = hostname;
    networking.networkmanager.enable = true;

    nixpkgs.hostPlatform = "x86_64-linux";
    system.stateVersion = "25.11";
  };
}
