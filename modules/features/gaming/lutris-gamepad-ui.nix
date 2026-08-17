{ ... }:
{
  flake.modules.nixos.gaming = { pkgs, ... }: let
    lutris-gamepad-ui = pkgs.appimageTools.wrapType2 {
      pname = "lutris-gamepad-ui";
      version = "0.2.0";
      src = pkgs.fetchurl {
        url = "https://github.com/andrew-ld/lutris-gamepad-ui/releases/download/v0.2.0/lutris-gamepad-ui-x64.AppImage";
        sha256 = "b5f8df70cc15efd9be070ac77c10b0dec6d0433489055a5784da5baad6deff6f";
      };
      meta.mainProgram = "lutris-gamepad-ui";
    };
  in
  {
    environment.systemPackages = [ lutris-gamepad-ui ];
  };
}
