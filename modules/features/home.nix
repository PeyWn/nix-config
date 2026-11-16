{ config, lib, inputs, ... }:
let
  hmModules = lib.attrValues config.homeManagerModules;
  base = config.flake.modules.homeManager.base;
in
{
  flake.modules.homeManager.base = { lib, scheme, username, ... }:
    let
      p = scheme.palette;
    in
    {
      imports =
        [
          inputs.nix-colors.homeManagerModules.default
          inputs.lazyvim-nix.homeManagerModules.default
        ]
        ++ hmModules;
      _module.args.colors = {
        base00 = p.bg0;   base08 = p.red;
        base01 = p.bg1;   base09 = p.orange;
        base02 = p.bg2;   base0A = p.yellow;
        base03 = p.grey0; base0B = p.green;
        base04 = p.grey1; base0C = p.aqua;
        base05 = p.fg;    base0D = p.blue;
        base06 = p.grey2; base0E = p.purple;
        base07 = p.bg4;   base0F = p.orange;
      };
      home.username = lib.mkDefault username;
      home.homeDirectory = lib.mkDefault "/home/${username}";
      home.stateVersion = "25.11";
      colorScheme = scheme;
    };

  flake.modules.nixos.home = { username, hostname, scheme, ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "bak";
      extraSpecialArgs = {
        inherit scheme username hostname;
      };
      users.${username}.imports = [ base ];
    };
  };
}
