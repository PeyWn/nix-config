{ inputs, ... }:
{
  flake.modules.nixos.noctalia = { pkgs, ... }:
    let
      wrapped-noctalia = inputs.nix-wrapper-modules.wrappers.noctalia-shell.wrap {
        inherit pkgs;
        outOfStoreConfig = "$HOME/.config/noctalia";
        colors = {
          mError = "#f7768e";
          mHover = "#7aa2f7";
          mOnError = "#1a1b26";
          mOnHover = "#1a1b26";
          mOnPrimary = "#1a1b26";
          mOnSecondary = "#1a1b26";
          mOnSurface = "#c0caf5";
          mOnSurfaceVariant = "#9aa5ce";
          mOnTertiary = "#1a1b26";
          mOutline = "#3b4261";
          mPrimary = "#7aa2f7";
          mSecondary = "#e0af68";
          mShadow = "#1a1b26";
          mSurface = "#1a1b26";
          mSurfaceVariant = "#24283b";
          mTertiary = "#9ece6a";
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
