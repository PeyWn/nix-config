{ ... }:
{
  flake.modules.nixos.desktop = { pkgs, ... }: {
    services.xserver.enable = true;

    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ];
    };

    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-emoji
    ];

    services.dbus.enable = true;

    services.greetd.enable = true;
  };
}
