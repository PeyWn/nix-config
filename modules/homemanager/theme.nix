{ ... }:
{
  flake.modules.nixos.home = { username, scheme, ... }:
    let
      p = scheme.palette;
      slug = scheme.slug or "everforest-light";
      isDark = scheme.variant == "dark";

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

      openCodeTheme = mkOpenCodeTheme p;
      openCodeThemeName =
        if slug == "everforest" then "everforest"
        else slug;
    in
    {
      home-manager.users.${username} = {
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
      };
    };
}
