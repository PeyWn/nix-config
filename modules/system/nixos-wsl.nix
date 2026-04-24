{ inputs, ... }:
{
  flake.modules.nixos.wsl = { username, ... }: {
    imports = [ inputs.nixos-wsl.nixosModules.default ];
    wsl.enable = true;
    wsl.defaultUser = username;
    programs.nix-ld.enable = true;
  };
}
