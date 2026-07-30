{ ... }:
{
  flake.modules.nixos.shell = { pkgs, ... }: {
    # glances 
    environment.systemPackages = with pkgs; [ just bat htop btop gtop glow ];
  };
}
