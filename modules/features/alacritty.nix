{ inputs, ... }:
{
  flake.modules.nixos.alacritty = { pkgs, config, ... }:
    let
      c = config.theme.colors;
      wrapped-alacritty = inputs.nix-wrapper-modules.wrappers.alacritty.wrap {
        inherit pkgs;
        settings = {
          window = {
            opacity = 0.95;
            padding = {
              x = 8;
              y = 4;
            };
          };
          terminal.shell = {
            program = "${pkgs.zsh}/bin/zsh";
            args = [ "-l" ];
          };
          font = {
            size = 12;
            normal.family = "JetBrainsMono Nerd Font";
          };
          colors = {
            primary = {
              background = "#${c.base00}";
              foreground = "#${c.base05}";
            };
            normal = {
              black = "#${c.base00}";
              red = "#${c.base08}";
              green = "#${c.base0B}";
              yellow = "#${c.base0A}";
              blue = "#${c.base0D}";
              magenta = "#${c.base0E}";
              cyan = "#${c.base0C}";
              white = "#${c.base05}";
            };
            bright = {
              black = "#${c.base01}";
              red = "#${c.base08}";
              green = "#${c.base0B}";
              yellow = "#${c.base0A}";
              blue = "#${c.base0D}";
              magenta = "#${c.base0E}";
              cyan = "#${c.base0C}";
              white = "#${c.base07}";
            };
          };
        };
      };
    in
    {
      environment.systemPackages = [ wrapped-alacritty ];
    };
}
