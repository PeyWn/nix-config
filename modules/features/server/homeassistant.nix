{ ... }:
{
  flake.modules.nixos.server = { config, lib, pkgs, ... }: {
    services.home-assistant = {
      enable = true;

      # Makes configuration.yaml writable for the hass user.
      # Needed for UI-based config changes (e.g., adding integrations via the web UI).
      configWritable = true;

      # Open the Home Assistant web UI port (8123) in the firewall.
      openFirewall = true;

      extraComponents = [
        "default_config"
        "cloud" # Nabu Casa remote access
        "met"
        "esphome"
        "zha" # Zigbee Home Automation — requires a Zigbee coordinator dongle (e.g., SkyConnect, Conbee II)
        "matter" # Matter/Thread smart home protocol — requires IPv6 + a Thread border router
      ];

      # Add more integrations here as needed, e.g.:
      # extraComponents = [
      #   "mqtt"        # MQTT broker support — needs an external MQTT broker (e.g., mosquitto)
      #   "tasmota"     # Tasmota-flashed devices
      #   "wled"        # WLED light strips
      #   "ffmpeg"      # Camera/stream processing
      #   "homekit"     # Apple HomeKit bridge
      #   "google_assistant" # Google Assistant integration
      #   "spotify"     # Spotify media player
      #   "govee"        # Govee smart lights
      # ];

      # Extra Python packages for component dependencies.
      # extraPackages = python3Packages: with python3Packages; [
      #   psycopg2   # PostgreSQL recorder backend (replaces default SQLite)
      #   paho-mqtt  # MQTT support
      # ];

      # Custom components (HACS installed declaratively).
      customComponents = [
        (pkgs.stdenv.mkDerivation {
          pname = "hacs";
          version = "2.0.5";
          src = pkgs.fetchFromGitHub {
            owner = "hacs";
            repo = "integration";
            rev = "2.0.5";
            sha256 = "sha256-xj+H75A6iwyGzMvYUjx61aGiH5DK/qYLC6clZ4cGDac=";
          };
          installPhase = ''
            mkdir -p $out
            cp -r custom_components/hacs $out/
          '';
          domain = "hacs";
          isHomeAssistantComponent = true;
        })
      ];

      # Other popular custom components from nixpkgs:
      # customComponents = with pkgs.home-assistant-custom-components; [
      #   frigate     # Frigate NVR integration
      #   powercalc   # Virtual power sensors
      #   spook       # Entity utilities
      # ];

      config = {
        homeassistant = {
          name = "Home";
          # Latitude of your location — used for sun rise/set calculations.
          # latitude = 52.3;
          # Longitude of your location.
          # longitude = 4.9;
          # Unit system: "metric" (Celsius, km/h) or "us_customary" (Fahrenheit, mph).
          unit_system = "metric";
          # Override the temperature unit set by unit_system. "C" or "F".
          temperature_unit = "C";
          # Time zone — defaults to system time zone.
          # time_zone = "Europe/Amsterdam";
        };
      };

      # Static Lovelace dashboard YAML config. Set to null to manage dashboards via the UI.
      # lovelaceConfig = {
      #   title = "Home";
      #   views = [
      #     {
      #       title = "Overview";
      #       cards = [ ];
      #     }
      #   ];
      # };
    };

    # Matter requires IPv6. Most NixOS configs enable this by default,
    # but uncomment if your kernel/network config has it disabled.
    # networking.enableIPv6 = true;
  };
}
