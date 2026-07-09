{ ... }:
let
  customSchemes = {
    everforest-dark = {
      slug = "everforest-dark";
      name = "Everforest Dark";
      author = "Sainnhe Park";
      variant = "dark";
      palette = {
        bg_dim    = "293136";
        bg0       = "333c43";
        bg1       = "3a464c";
        bg2       = "434f55";
        bg3       = "4d5960";
        bg4       = "555f66";
        bg5       = "5d6b66";
        bg_visual = "5c3f4f";
        bg_red    = "59464c";
        bg_yellow = "55544a";
        bg_green  = "48584e";
        bg_blue   = "3f5865";
        bg_purple = "4e4953";
        fg       = "d3c6aa";
        red      = "e67e80";
        orange   = "e69875";
        yellow   = "dbbc7f";
        green    = "a7c080";
        aqua     = "83c092";
        blue     = "7fbbb3";
        purple   = "d699b6";
        grey0    = "7a8478";
        grey1    = "859289";
        grey2    = "9da9a0";
        statusline1 = "a7c080";
        statusline2 = "d3c6aa";
        statusline3 = "e67e80";
      };
    };
    everforest-light = {
      slug = "everforest-light";
      name = "Everforest Light";
      author = "Sainnhe Park";
      variant = "light";
      palette = {
        bg_dim    = "e5dfc5";
        bg0       = "f3ead3";
        bg1       = "eae4ca";
        bg2       = "e5dfc5";
        bg3       = "ddd8be";
        bg4       = "d8d3ba";
        bg5       = "b9c0ab";
        bg_visual = "e1e4bd";
        bg_red    = "fadbd0";
        bg_yellow = "f1e4c5";
        bg_green  = "e5e6c5";
        bg_blue   = "e1e7dd";
        bg_purple = "f1ddd4";
        fg       = "5c6a72";
        red      = "f85552";
        orange   = "f57d26";
        yellow   = "dfa000";
        green    = "8da101";
        aqua     = "35a77c";
        blue     = "3a94c5";
        purple   = "df69ba";
        grey0    = "a6b0a0";
        grey1    = "939f91";
        grey2    = "829181";
        statusline1 = "93b259";
        statusline2 = "708089";
        statusline3 = "e66868";
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
      palette = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        readOnly = true;
      };
    };

    config.theme = {
      colors = {
        base00 = p.bg0;       base08 = p.red;
        base01 = p.bg1;       base09 = p.orange;
        base02 = p.bg2;       base0A = p.yellow;
        base03 = p.grey0;     base0B = p.green;
        base04 = p.grey1;     base0C = p.aqua;
        base05 = p.fg;        base0D = p.blue;
        base06 = p.grey2;     base0E = p.purple;
        base07 = p.bg4;       base0F = p.orange;
      };
      palette = p;
    };
  };

  flake.customSchemes = customSchemes;
}
