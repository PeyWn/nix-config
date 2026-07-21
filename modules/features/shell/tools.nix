{ ... }:
{
  flake.modules.nixos.shell = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ just bat htop btop glances gtop glow ];
  };
}
