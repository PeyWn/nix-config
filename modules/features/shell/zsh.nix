{ ... }:
{
  flake.modules.nixos.shell = {
    programs.zsh.enable = true;
    programs.git.enable = true;
    security.sudo.wheelNeedsPassword = true;
  };
}
