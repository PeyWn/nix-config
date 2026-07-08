{ config, ... }:
{
  flake.modules.nixos.kde = { pkgs, config, ... }: {
    services.xserver.enable = true;

    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;

    services.xserver.xkb = {
      layout = "us";
      variant = "";
      options = "caps:escape";
    };

    qt = {
      enable = true;
      platformTheme = "kde";
    };
  };
}
