{ inputs, ... }:
{
  flake.modules.nixos.shell = { pkgs, ... }: {
    environment.systemPackages = [ inputs.herdr.packages.${pkgs.system}.default ];
  };
}
