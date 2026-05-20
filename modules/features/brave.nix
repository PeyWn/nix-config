{ ... }:
{
  flake.modules.nixos.brave = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.brave ];
  };
}
