{ lib, ... }:
{
  flake.modules.nixos.gaming = { pkgs, ... }: {
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "steam"
      "steam-unwrapped"
      "steam-original"
      "steam-run"
    ];
    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
      protontricks.enable = true;
      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      extraPackages = with pkgs; [ extest libva ];
    };

    programs.gamemode.enable = true;

    programs.gamescope.enable = true;

    environment.systemPackages = [ pkgs.mangohud ];
  };
}
