{ ... }:
{
  flake.modules.nixos.shell = { pkgs, ... }: {
    programs.zsh.enable = true;
    environment.systemPackages = with pkgs; [ ripgrep fzf ];
    security.sudo.wheelNeedsPassword = true;
  };
}
