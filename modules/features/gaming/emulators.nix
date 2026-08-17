{ ... }:
{
  flake.modules.nixos.gaming = { pkgs, ... }: let
    retroarch-with-cores = pkgs.retroarch.withCores (
      cores: with cores; [
        mgba
        melonds
        mupen64plus
      ]
    );
  in
  {
    environment.systemPackages = [
      retroarch-with-cores
      pkgs.dolphin-emu
    ];
  };
}
