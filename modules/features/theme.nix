{ ... }:
let
  customSchemes = {
    everforest = {
      slug = "everforest";
      name = "Everforest";
      author = "Sainnhe Park";
      variant = "dark";
      palette = {
        base00 = "2d353b";
        base01 = "343f44";
        base02 = "3d484d";
        base03 = "7a8478";
        base04 = "9da9a0";
        base05 = "d3c6aa";
        base06 = "e4e1cd";
        base07 = "fdf6e3";
        base08 = "e67e80";
        base09 = "e69875";
        base0A = "dbbc7f";
        base0B = "a7c080";
        base0C = "83c092";
        base0D = "7fbbb3";
        base0E = "d699b6";
        base0F = "56635f";
      };
    };
    solarized-dark = {
      slug = "solarized-dark";
      name = "Solarized Dark";
      author = "Ethan Schoonover";
      variant = "dark";
      palette = {
        base00 = "002b36";
        base01 = "073642";
        base02 = "586e75";
        base03 = "657b83";
        base04 = "839496";
        base05 = "93a1a1";
        base06 = "eee8d5";
        base07 = "fdf6e3";
        base08 = "dc322f";
        base09 = "cb4b16";
        base0A = "b58900";
        base0B = "859900";
        base0C = "2aa198";
        base0D = "268bd2";
        base0E = "6c71c4";
        base0F = "d33682";
      };
    };
    everforest-light = {
      slug = "everforest-light";
      name = "Everforest Light";
      author = "Sainnhe Park";
      variant = "light";
      palette = {
        base00 = "fdf6e3";
        base01 = "f4f0d9";
        base02 = "efebd4";
        base03 = "a6b0a0";
        base04 = "829181";
        base05 = "5c6a72";
        base06 = "2d353b";
        base07 = "d3c6aa";
        base08 = "f85552";
        base09 = "f57d26";
        base0A = "dfa000";
        base0B = "8da101";
        base0C = "35a77c";
        base0D = "3a94c5";
        base0E = "df69ba";
        base0F = "bdc3af";
      };
    };
  };
in {
  flake.modules.nixos.theme = { config, lib, scheme, ... }: let
    p = scheme.palette;
  in {
    options.theme = {
      name = lib.mkOption {
        type = lib.types.str;
        default = scheme.slug;
      };
      variant = lib.mkOption {
        type = lib.types.enum [ "dark" "light" ];
        default = scheme.variant or "light";
      };
      colors = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        readOnly = true;
      };
    };

    config.theme.colors = {
      base00 = p.base00;
      base01 = p.base01;
      base02 = p.base02;
      base03 = p.base03;
      base04 = p.base04;
      base05 = p.base05;
      base06 = p.base06;
      base07 = p.base07;
      base08 = p.base08;
      base09 = p.base09;
      base0A = p.base0A;
      base0B = p.base0B;
      base0C = p.base0C;
      base0D = p.base0D;
      base0E = p.base0E;
      base0F = p.base0F;
      bg = p.base00;
      bgAlt = p.base01;
      bgSelection = p.base02;
      fg = p.base05;
      fgDim = p.base04;
      fgMuted = p.base03;
      red = p.base08;
      orange = p.base09;
      yellow = p.base0A;
      green = p.base0B;
      cyan = p.base0C;
      blue = p.base0D;
      purple = p.base0E;
      magenta = p.base0F;
      border = p.base02;
      brightBg = p.base07;
      brightFg = p.base06;
    };
  };

  flake.customSchemes = customSchemes;
}
