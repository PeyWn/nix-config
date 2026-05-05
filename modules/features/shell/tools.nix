{ ... }:
{
  flake.modules.nixos.shell = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ just ranger bat htop gtop glow ];
  };
}
