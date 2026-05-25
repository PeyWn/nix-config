{ ... }:
{
  flake.modules.nixos.server = { config, lib, pkgs, ... }: {
    services.home-assistant = {
      enable = true;

      configWritable = true;

      openFirewall = true;

      extraComponents = [
        "default_config"
        "cloud"
        "met"
        "esphome"
        "zha"
        "matter"
        "mobile_app"
        "google_assistant"
      ];

      # Custom integrations come from the runtime config (HACS, Nordpool, MASS)
      # migrated from the backup. No Nix-managed custom components to avoid
      # collision with runtime-managed ones.
      customComponents = [];

      # Provide Python dependencies for custom components from the backup.
      # backoff: required by Nordpool.
      # If nordpool or music-assistant Python packages are missing, the
      # integration won't start -- install via HACS UI after migration.
      extraPackages = python3Packages: with python3Packages; [
        backoff
      ];

      config = {
        homeassistant = {
          name = "Home";
          latitude = 58.4186863;
          longitude = 15.496391200000001;
          unit_system = "metric";
          temperature_unit = "C";
          time_zone = "Europe/Stockholm";
          currency = "SEK";
          country = "SE";
        };
      };
    };

    # Allow Home Assistant to access USB serial devices (Zigbee coordinator).
    users.users.hass.extraGroups = [ "dialout" ];

    # Append YAML include directives after the Nix-generated configuration.yaml
    # is written. The cp in preStart overwrites the file, so no duplication risk.
    systemd.services.home-assistant.preStart = lib.mkAfter ''
      cat >> /var/lib/hass/configuration.yaml << 'YAML'

automation: !include automations.yaml
script: !include scripts.yaml
scene: !include scenes.yaml
YAML
    '';
  };
}
