{ inputs, ... }:
{
  flake.modules.nixos.alacritty = { pkgs, ... }:
    let
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
            normal.family = "monospace";
          };
          colors = {
            primary = {
              background = "#1a1b26";
              foreground = "#c0caf5";
            };
          };
        };
      };
    in
    {
      environment.systemPackages = [ wrapped-alacritty ];
    };
}
