{ ... }:
{
  flake.modules.nixos.server = { lib, ... }: {
    virtualisation.oci-containers = {
      backend = "podman";
      containers."homeassistant" = {
        image = "ghcr.io/home-assistant/home-assistant:stable";
        autoStart = true;
        volumes = [
          "/var/lib/hass:/config"
          "/etc/localtime:/etc/localtime:ro"
          "/run/dbus:/run/dbus:ro"
          "/var/run/avahi-daemon/socket:/var/run/avahi-daemon/socket:ro"
        ];
        environment = {
          TZ = "Europe/Stockholm";
        };
        extraOptions = [
          "--network=host"
          "--device=/dev/serial/by-id/usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_56273dd08b45ed1192d9c58f0a86e0b4-if00-port0"
        ];
      };
    };

    services.matter-server = {
      enable = true;
      extraArgs.primary-interface = "wlp4s0";
    };

    services.avahi = {
      enable = true;
      nssmdns = true;
    };

    systemd.services.matter-server.serviceConfig = {
      ProtectProc = lib.mkForce "default";
      BindReadOnlyPaths = [ "/sys/class/net" ];
    };

    networking.firewall = {
      allowedTCPPorts = [ 8123 ];
      allowedUDPPorts = [ 5353 ];
      extraCommands = ''
        iptables -A nixos-fw -p udp -d 224.0.0.251 --dport 5353 -j nixos-fw-accept
      '';
    };
  };
}
