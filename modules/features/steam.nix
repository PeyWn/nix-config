{ ... }:
{
  flake.modules.nixos.steam = { pkgs, ... }: {
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
