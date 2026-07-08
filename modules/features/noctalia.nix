{ inputs, ... }:
{
  flake.modules.nixos.noctalia = { pkgs, config, ... }:
    let
      c = config.theme.colors;
      wrapped-noctalia = inputs.nix-wrapper-modules.wrappers.noctalia-shell.wrap {
        inherit pkgs;
        outOfStoreConfig = "$HOME/.config/noctalia";
        colors = {
          mPrimary = "#${c.base0D}";
          mSecondary = "#${c.base0A}";
          mTertiary = "#${c.base0B}";
          mError = "#${c.base08}";
          mSurface = "#${c.base00}";
          mSurfaceVariant = "#${c.base01}";
          mOnPrimary = "#${c.base00}";
          mOnSecondary = "#${c.base00}";
          mOnTertiary = "#${c.base00}";
          mOnSurface = "#${c.base05}";
          mOnSurfaceVariant = "#${c.base04}";
          mOnError = "#${c.base00}";
          mHover = "#${c.base0D}";
          mOnHover = "#${c.base00}";
          mOutline = "#${c.base02}";
          mShadow = "#${c.base00}";
        };
        settings = {
          bar = {
            position = "left";
            floating = false;
            exclusive = true;
            density = "comfortable";
            widgets = {
              center = [ ];
              left = [
                { id = "ControlCenter"; enableColorization = true; }
                { id = "Workspace"; showApplications = false; labelMode = "none"; }
              ];
              right = [
                { id = "NotificationHistory"; }
                { id = "Volume"; }
                { id = "Battery"; hideIfNotDetected = true; }
                { id = "Clock"; usePrimaryColor = true; }
                { id = "Tray"; drawerEnabled = true; }
              ];
            };
          };
          general = {
            animationSpeed = 1.0;
            radiusRatio = 1.0;
            screenRadiusRatio = 1.0;
          };
          ui = {
            fontDefault = "Sans Serif";
            fontFixed = "JetBrainsMono Nerd Font";
          };
        };
      };
    in
    {
      environment.systemPackages = [ wrapped-noctalia ];
    };
}
