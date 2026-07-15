{ ... }:
{
  homeManagerModules.theme = { scheme, ... }:
    let
      isDark = scheme.variant == "dark";
    in
    {
      home.file.".config/opencode/tui.json".text = builtins.toJSON {
        "$schema" = "https://opencode.ai/tui.json";
        theme = "system";
      };

      home.file.".config/glow/glow.yml".text = "style: \"${if isDark then "dark" else "light"}\"\n";

      home.file.".config/herdr/config.toml".text = ''
        [theme]
        name = "terminal"
      '';
    };
}
