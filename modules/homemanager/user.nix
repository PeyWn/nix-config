{ inputs, ... }:
{
  flake.modules.nixos.home = { lib, username, ... }: {
    home-manager.users.${username} = {
      home.username = lib.mkDefault username;
      home.homeDirectory = lib.mkDefault "/home/${username}";
      home.stateVersion = "25.11";
      imports = [
        inputs.nix-colors.homeManagerModules.default
        inputs.lazyvim-nix.homeManagerModules.default
      ];
    };
  };
}
