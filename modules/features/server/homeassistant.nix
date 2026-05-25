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

      customComponents = [];

      extraPackages = python3Packages: with python3Packages; [
        aioelectricitymaps
        gtts
        pychromecast
        radios
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

    users.users.hass.extraGroups = [ "dialout" ];

    # Wait for wlp4s0 to get an IPv4 address before starting HA, then append
    # YAML include directives after the Nix-generated configuration.yaml.
    systemd.services.home-assistant.preStart = lib.mkMerge [
      (lib.mkBefore ''
        while ! ${pkgs.iproute2}/bin/ip addr show wlp4s0 2>/dev/null | grep -q "inet " ; do
          sleep 1
        done
      '')
      (lib.mkAfter ''
        cat >> /var/lib/hass/configuration.yaml << 'YAML'

automation: !include automations.yaml
script: !include scripts.yaml
scene: !include scenes.yaml
YAML
      '')
    ];
  };
}
