{ inputs, ... }:
{
  flake.modules.nixos.home = { lib, username, ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.${username} = {
      home.username = lib.mkDefault username;
      home.homeDirectory = lib.mkDefault "/home/${username}";
    };
  };
}
