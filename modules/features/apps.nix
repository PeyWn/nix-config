{ inputs, ... }:
{
  flake.modules.nixos.apps = { pkgs, ... }: {
    services.portmaster.enable = true;
    environment.systemPackages =
      (with pkgs; [
        brave
        portmaster
        nordvpn
      ])
      ++ [ inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default ];
  };
}
