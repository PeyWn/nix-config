{ ... }:
{
  flake.modules.homeManager.generic-linux = {
    programs.home-manager.enable = true;
    targets.genericLinux.enable = true;
    targets.genericLinux.gpu.enable = false;
  };
}
