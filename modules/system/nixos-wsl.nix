{ inputs, ... }:
{
  flake.modules.nixos.wsl = { pkgs, username, ... }: {
    imports = [ inputs.nixos-wsl.nixosModules.default ];
    wsl.enable = true;
    wsl.defaultUser = username;
    wsl.docker-desktop.enable = false;
    services.dbus.enable = true;
    systemd.user = {
      sockets.dbus-broker = {
        wantedBy = [ "sockets.target" ];
      };
      services.dbus-broker = {
        wantedBy = [ "default.target" ];
      };
    };
    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
      icu
      openssl
      zlib
      curl
      libkrb5
    ];
  };
}
