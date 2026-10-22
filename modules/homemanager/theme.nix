{ ... }:
{
  homeManagerModules.theme = { scheme, ... }:
    let
      p = scheme.palette;
      isDark = scheme.variant == "dark";
    in
    {
      home.file.".config/opencode/cli.json".text = builtins.toJSON {
        "$schema" = "https://opencode.ai/v2/cli.json";
        theme = {
          name = "nix-colors";
          mode = scheme.variant;
        };
      };

      home.file.".config/opencode/themes/nix-colors.json".text = builtins.toJSON {
        "$schema" = "https://opencode.ai/theme.json";
        theme = {
          primary = "#${p.blue}";
          secondary = "#${p.purple}";
          accent = "#${p.aqua}";
          error = "#${p.red}";
          warning = "#${p.orange}";
          success = "#${p.green}";
          info = "#${p.aqua}";
          text = "#${p.fg}";
          textMuted = "#${p.grey0}";
          selectedListItemText = "#${p.bg0}";
          background = "#${p.bg0}";
          backgroundPanel = "#${p.bg1}";
          backgroundElement = "#${p.bg2}";
          backgroundMenu = "#${p.bg2}";
          border = "#${p.bg2}";
          borderActive = "#${p.grey0}";
          borderSubtle = "#${p.bg1}";
          diffAdded = "#${p.green}";
          diffRemoved = "#${p.red}";
          diffContext = "#${p.grey0}";
          diffHunkHeader = "#${p.grey0}";
          diffHighlightAdded = "#${p.green}";
          diffHighlightRemoved = "#${p.red}";
          diffAddedBg = "#${p.bg1}";
          diffRemovedBg = "#${p.bg1}";
          diffContextBg = "#${p.bg1}";
          diffLineNumber = "#${p.grey0}";
          diffAddedLineNumberBg = "#${p.bg1}";
          diffRemovedLineNumberBg = "#${p.bg1}";
          markdownText = "#${p.fg}";
          markdownHeading = "#${p.blue}";
          markdownLink = "#${p.aqua}";
          markdownLinkText = "#${p.blue}";
          markdownCode = "#${p.green}";
          markdownBlockQuote = "#${p.grey0}";
          markdownEmph = "#${p.orange}";
          markdownStrong = "#${p.yellow}";
          markdownHorizontalRule = "#${p.grey0}";
          markdownListItem = "#${p.aqua}";
          markdownListEnumeration = "#${p.aqua}";
          markdownImage = "#${p.blue}";
          markdownImageText = "#${p.aqua}";
          markdownCodeBlock = "#${p.fg}";
          syntaxComment = "#${p.grey0}";
          syntaxKeyword = "#${p.purple}";
          syntaxFunction = "#${p.blue}";
          syntaxVariable = "#${p.fg}";
          syntaxString = "#${p.green}";
          syntaxNumber = "#${p.orange}";
          syntaxType = "#${p.aqua}";
          syntaxOperator = "#${p.aqua}";
          syntaxPunctuation = "#${p.fg}";
        };
      };

      home.file.".config/glow/glow.yml".text = "style: \"${if isDark then "dark" else "light"}\"\n";
    };
}
