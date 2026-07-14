{ lib, ... }:
let
  gamescopeSessionEnable = lib.mkDefault true;
in
{
  flake.modules.nixos.gaming = { pkgs, ... }: let
    lutris-gamescope = pkgs.writeShellScriptBin "lutris-gamescope" ''
      gamescope -- lutris
    '';

    gamescopeSessionFile = (pkgs.writeTextDir "share/wayland-sessions/lutris.desktop" ''
      [Desktop Entry]
      Name=Lutris (Gamescope)
      Comment=Open source gaming platform via Gamescope
      Exec=${lutris-gamescope}/bin/lutris-gamescope
      Type=Application
    '').overrideAttrs (_: {
      passthru.providedSessions = [ "lutris" ];
    });
  in
  {
    environment.systemPackages = [
      pkgs.lutris
      lutris-gamescope
    ];

    services.displayManager.sessionPackages = [ gamescopeSessionFile ];
  };
}
