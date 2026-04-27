{ config, ... }:
let
  hostname = "WSL-Home";
  username = "bjorn";
  inherit (config.flake.modules) nixos homeManager;
in
{
  configurations.nixos.${hostname}.module = {
    _module.args = { inherit username hostname; };
    imports = [
      nixos.nix
      nixos.wsl
      nixos.shell
      nixos.git
      nixos.devenv
      nixos.ssh
      {
        imports = [ nixos.home ];
        home-manager.backupFileExtension = "bak";
        home-manager.extraSpecialArgs = { inherit username hostname; };
        home-manager.users.${username} = {
          imports = [
            homeManager.shell
            homeManager.lazyvim
          ];
          home.username = username;
          home.homeDirectory = "/home/${username}";
          home.stateVersion = "25.11";
        };
      }
    ];
    nixpkgs.hostPlatform = "x86_64-linux";
    networking.hostName = hostname;
    system.stateVersion = "25.11";
  };
}
