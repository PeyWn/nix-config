{ inputs, lib, config, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.modules
  ];

  options.configurations.nixos = lib.mkOption {
    type = lib.types.lazyAttrsOf (
      lib.types.submodule {
        options.module = lib.mkOption {
          type = lib.types.deferredModule;
        };
      }
    );
  };

  config.flake.nixosConfigurations = lib.flip lib.mapAttrs config.configurations.nixos (
    name: { module }: lib.nixosSystem { modules = [ module ]; }
  );

  config.flake.modules.nixos.nix = {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
  };
}
