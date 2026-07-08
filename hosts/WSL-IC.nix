{ inputs, config, ... }:
let
  hostname = "WSL-IC";
  username = "bjorn";
  scheme = config.flake.customSchemes.everforest-light;
  inherit (config.flake.modules) nixos homeManager;
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
      nixos.devops
      nixos.ssh
      nixos.nixmate
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
    nixpkgs.hostPlatform = "x86_64-linux";
    networking.hostName = hostname;
    system.stateVersion = "25.11";
  };
}
