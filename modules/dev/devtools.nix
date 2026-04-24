{ ... }:
{
  flake.modules.nixos.devtools = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      ranger
    ];
  };
}
