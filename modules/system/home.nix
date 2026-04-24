{ inputs, ... }:
{
  flake.modules.nixos.home = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
  };
}
