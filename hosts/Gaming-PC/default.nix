{ inputs, config, ... }:
let
  hostname = "Gaming-PC";
  username = "peywn";
  scheme = let
    themeEnv = builtins.getEnv "NIX_THEME";
  in if themeEnv != "" then config.flake.customSchemes.${themeEnv}
     else config.flake.customSchemes.everforest-dark;
  inherit (config.flake.modules) homeManager;
in
{
  configurations.home."${username}@${hostname}" = {
    system = "x86_64-linux";
    module = {
      _module.args = { inherit username hostname scheme; };
      home.sessionVariables.PROTON_ENABLE_WAYLAND = "1";
      imports = [
        homeManager.base
        homeManager.generic-linux
      ];
    };
  };
}
