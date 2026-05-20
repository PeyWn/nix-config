{ inputs, ... }:
{
  flake.modules.nixos.niri = { pkgs, ... }:
    let
      wrapped-niri = inputs.nix-wrapper-modules.wrappers.niri.wrap {
        inherit pkgs;
        settings = {
          input.keyboard.xkb = {
            layout = "us";
          };
          spawn-at-startup = [
            "noctalia-shell"
          ];
          binds = {
            "Mod+T".spawn-sh = "alacritty";
            "Mod+B".spawn-sh = "brave";
            "Mod+Q".close-window = { };
            "Mod+Slash".spawn-sh = "fuzzel";
            "Mod+H".focus-column-left = { };
            "Mod+L".focus-column-right = { };
            "Mod+J".focus-window-or-workspace-down = { };
            "Mod+K".focus-window-or-workspace-up = { };
            "Mod+Shift+H".move-column-left = { };
            "Mod+Shift+L".move-column-right = { };
            "Mod+Shift+J".move-window-down-or-to-workspace-down = { };
            "Mod+Shift+K".move-window-up-or-to-workspace-up = { };
            "Mod+1".focus-workspace = 1;
            "Mod+2".focus-workspace = 2;
            "Mod+3".focus-workspace = 3;
            "Mod+4".focus-workspace = 4;
            "Mod+5".focus-workspace = 5;
            "Mod+Shift+1".move-window-to-workspace = 1;
            "Mod+Shift+2".move-window-to-workspace = 2;
            "Mod+Shift+3".move-window-to-workspace = 3;
            "Mod+Shift+4".move-window-to-workspace = 4;
            "Mod+Shift+5".move-window-to-workspace = 5;
            "Mod+Return".switch-preset-column-width = { };
            "Mod+Shift+R".reset-window-height = { };
          };
          layout = {
            gap = 4;
            border = {
              width = 2;
              active-color = "#7aa2f7";
              inactive-color = "#3b4261";
            };
            focus-ring.enable = true;
            struts.left = 48;
          };
        };
      };
    in
    {
      environment.systemPackages = [ wrapped-niri ];

      services.greetd.settings.default_session.command =
        "${pkgs.tuigreet}/bin/tuigreet --time --cmd ${wrapped-niri}/bin/niri";
    };
}
