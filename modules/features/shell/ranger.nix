{ ... }:
{
  flake.modules.nixos.shell = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.ranger pkgs.bat ];
  };
}
