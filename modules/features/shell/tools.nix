{ ... }:
{
  flake.modules.nixos.shell = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ just ranger bat ];
  };
}
