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

  options.configurations.home = lib.mkOption {
    type = lib.types.lazyAttrsOf (
      lib.types.submodule {
        options.system = lib.mkOption {
          type = lib.types.str;
        };
        options.module = lib.mkOption {
          type = lib.types.deferredModule;
        };
      }
    );
  };

  options.homeManagerModules = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.unspecified;
    default = { };
  };

  config.flake.nixosConfigurations = lib.flip lib.mapAttrs config.configurations.nixos (
    name: { module }: lib.nixosSystem { modules = [ module ]; }
  );

  config.flake.homeConfigurations = lib.flip lib.mapAttrs config.configurations.home (
    name: { system, module }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      modules = [ module ];
    }
  );

  config.flake.modules.nixos.nix = {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
  };
}
