{ inputs, ... }:
{
  flake.modules.nixos.nixmate = { pkgs, ... }: {
    environment.systemPackages = [ inputs.nixmate.packages.${pkgs.system}.default ];
  };
}
