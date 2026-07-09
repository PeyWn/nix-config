{ inputs, ... }:
{
  flake.modules.nixos.alacritty = { pkgs, config, ... }:
    let
      p = config.theme.palette;
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
              background = "#${p.bg0}";
              foreground = "#${p.fg}";
            };
            normal = {
              black   = "#${p.bg3}";
              red     = "#${p.red}";
              green   = "#${p.green}";
              yellow  = "#${p.yellow}";
              blue    = "#${p.blue}";
              magenta = "#${p.purple}";
              cyan    = "#${p.aqua}";
              white   = "#${p.fg}";
            };
            bright = {
              black   = "#${p.bg3}";
              red     = "#${p.red}";
              green   = "#${p.green}";
              yellow  = "#${p.yellow}";
              blue    = "#${p.blue}";
              magenta = "#${p.purple}";
              cyan    = "#${p.aqua}";
              white   = "#${p.fg}";
            };
            selection = {
              background = "#${p.bg_visual}";
              text       = "#${p.fg}";
            };
          };
        };
      };
    in
    {
      environment.systemPackages = [ wrapped-alacritty ];
    };
}
