{ inputs, ... }:
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

  isEverforest = slug: slug == "everforest" || slug == "everforest-light";
  isSolarized = slug: slug == "solarized-dark" || slug == "solarized-light";

  mkOpenCodeTheme = palette: {
    "$schema" = "https://opencode.ai/theme.json";
    theme = {
      primary = "#${palette.base0D}";
      secondary = "#${palette.base0C}";
      accent = "#${palette.base0E}";
      error = "#${palette.base08}";
      warning = "#${palette.base09}";
      success = "#${palette.base0B}";
      info = "#${palette.base0D}";
      text = "#${palette.base05}";
      textMuted = "#${palette.base03}";
      background = "#${palette.base00}";
      backgroundPanel = "#${palette.base01}";
      backgroundElement = "#${palette.base01}";
      border = "#${palette.base02}";
      borderActive = "#${palette.base04}";
      borderSubtle = "#${palette.base01}";
      diffAdded = "#${palette.base0B}";
      diffRemoved = "#${palette.base08}";
      diffContext = "#${palette.base03}";
      diffHunkHeader = "#${palette.base03}";
      diffHighlightAdded = "#${palette.base0B}";
      diffHighlightRemoved = "#${palette.base08}";
      diffAddedBg = "#${palette.base01}";
      diffRemovedBg = "#${palette.base01}";
      diffContextBg = "#${palette.base01}";
      diffLineNumber = "#${palette.base02}";
      diffAddedLineNumberBg = "#${palette.base01}";
      diffRemovedLineNumberBg = "#${palette.base01}";
      markdownText = "#${palette.base05}";
      markdownHeading = "#${palette.base0D}";
      markdownLink = "#${palette.base0D}";
      markdownLinkText = "#${palette.base0C}";
      markdownCode = "#${palette.base0B}";
      markdownBlockQuote = "#${palette.base03}";
      markdownEmph = "#${palette.base09}";
      markdownStrong = "#${palette.base0E}";
      markdownHorizontalRule = "#${palette.base02}";
      markdownListItem = "#${palette.base0D}";
      markdownListEnumeration = "#${palette.base0C}";
      markdownImage = "#${palette.base0D}";
      markdownImageText = "#${palette.base0C}";
      markdownCodeBlock = "#${palette.base05}";
      syntaxComment = "#${palette.base03}";
      syntaxKeyword = "#${palette.base0E}";
      syntaxFunction = "#${palette.base0D}";
      syntaxVariable = "#${palette.base06}";
      syntaxString = "#${palette.base0B}";
      syntaxNumber = "#${palette.base09}";
      syntaxType = "#${palette.base0A}";
      syntaxOperator = "#${palette.base0E}";
      syntaxPunctuation = "#${palette.base04}";
    };
  };
in {
  flake.modules.nixos.theme = { config, lib, scheme, ... }: let
    p = scheme.palette;
  in {
    options.theme = {
      name = lib.mkOption {
        type = lib.types.str;
        default = scheme.slug or "everforest-light";
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

  flake.modules.homeManager.theme = { config, lib, pkgs, scheme, ... }: let
    p = scheme.palette;
    slug = scheme.slug or "everforest-light";
    isDark = scheme.variant == "dark";
    isEv = isEverforest slug;
    isSol = isSolarized slug;

    openCodeTheme = mkOpenCodeTheme p;
    openCodeThemeName =
      if slug == "everforest" then "everforest"
      else slug;

    lazyvimColorschemePlugin =
      if isEv then ''
        return {
          "sainnhe/everforest",
          lazy = false,
          priority = 1000,
          config = function()
            vim.g.everforest_background = "medium"
            vim.o.background = "${if isDark then "dark" else "light"}"
            vim.cmd.colorscheme("everforest")
          end
        }
      ''
      else ''
        return {
          "lifepillar/vim-solarized8",
          lazy = false,
          priority = 1000,
          config = function()
            vim.g.solarized_visibility = "high"
            vim.cmd.colorscheme("solarized8_flat")
          end
        }
      '';
  in {
    imports = [ inputs.nix-colors.homeManagerModules.default ];
    colorScheme = scheme;

    home.file.".config/opencode/tui.json".text = builtins.toJSON {
      "$schema" = "https://opencode.ai/tui.json";
      theme = openCodeThemeName;
    };

    home.file.".config/opencode/themes/${slug}.json".text = builtins.toJSON openCodeTheme;

    home.file.".config/glow/glow.yml".text = "style: \"${if isDark then "dark" else "light"}\"\n";

    home.file.".config/herdr/config.toml".text = ''
      [theme]
      name = "custom"

      [theme.custom]
      panel_bg = "#${p.base00}"
      accent = "#${p.base0D}"
      green = "#${p.base0B}"
      blue = "#${p.base0D}"
      red = "#${p.base08}"
      yellow = "#${p.base0A}"
    '';

    programs.lazyvim.plugins.colorscheme = lazyvimColorschemePlugin;

    programs.starship.settings = {
      directory.style = "fg:#${p.base0D}";
      directory.format = "[ $path ]($style)";
      git_branch.style = "fg:#${p.base0B}";
      git_branch.format = "[ $symbol$branch ]($style)";
      git_branch.symbol = "󰊢 ";
      git_status.style = "fg:#${p.base0A}";
      git_status.format = "([$all_status$ahead_behind]($style) )";
      character.success_symbol = "[❯](bold #${p.base0B})";
      character.error_symbol = "[❯](bold #${p.base08})";
      cmd_duration.style = "fg:#${p.base04}";
      cmd_duration.format = "[   $duration ]($style)";
      nix_shell.style = "fg:#${p.base0E}";
      nix_shell.format = "[$symbol$state]($style)";
      nix_shell.symbol = "❄️  ";
      time.style = "fg:#${p.base04}";
      time.format = "[   $time ]($style)";
    };
  };

  flake.customSchemes = customSchemes;
}
