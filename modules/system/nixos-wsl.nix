{ inputs, ... }:
{
  flake.modules.nixos.wsl = { username, ... }: {
    imports = [ inputs.nixos-wsl.nixosModules.default ];
    wsl.enable = true;
    wsl.defaultUser = username;
    wsl.docker-desktop.enable = true;
    programs.nix-ld.enable = true;
  };
}
