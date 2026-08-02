{ ... }:
{
  flake.modules.nixos.power = { pkgs, ... }: let
    # supergfxd expects a writable /etc/supergfxd.conf to persist mode changes.
    # The stock services.supergfxd.settings option installs a read-only store
    # symlink which breaks runtime switching, so we seed a real file via
    # systemd.tmpfiles (C = copy once, never overwrites a runtime-modified file).
    supergfxdDefault = pkgs.writeText "supergfxd.conf" (builtins.toJSON {
      mode = "Hybrid";
      vfio_enable = false;
      vfio_save = false;
      always_reboot = false;
      no_logind = true;
      logout_timeout_s = 180;
      hotplug_type = "None";
    });

    # Man page for the power CLI, installed via systemPackages so `man power`
    # works from the profile's MANPATH.
    powerManPage = pkgs.writeTextFile {
      name = "power-man";
      destination = "/share/man/man1/power.1";
      text = builtins.readFile ./power.1;
    };
  in {
    services.tuned = {
      enable = true;
      ppdSupport = true;
    };
    services.power-profiles-daemon.enable = false;
    services.tlp.enable = false;

    services.supergfxd.enable = true;
    systemd.tmpfiles.rules = [
      "C /etc/supergfxd.conf - - - - ${supergfxdDefault}"
    ];
    environment.systemPackages = [
      pkgs.supergfxctl
      pkgs.supergfxctl-plasmoid
      (pkgs.writeShellApplication {
        name = "power";
        runtimeInputs = [
          pkgs.power-profiles-daemon
          pkgs.supergfxctl
          pkgs.coreutils
          pkgs.gnugrep
          pkgs.gawk
        ];
        text = builtins.readFile ./scripts/power.sh;
      })
      powerManPage
    ];
    hardware.nvidia.powerManagement = {
      enable = true;
      finegrained = true;
    };
  };
}
