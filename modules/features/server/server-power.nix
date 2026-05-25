{ ... }:
{
  flake.modules.nixos.server = { ... }: {
    services.logind.settings.Login.HandleLidSwitch = "ignore";
    services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";
    services.logind.settings.Login.HandleLidSwitchDocked = "ignore";
    systemd.sleep.settings.Sleep = {
      AllowSuspend = "no";
      AllowHibernation = "no";
      AllowSuspendThenHibernate = "no";
      AllowHybridSleep = "no";
    };
    systemd.targets.sleep.enable = false;
    systemd.targets.suspend.enable = false;
    systemd.targets.hibernate.enable = false;
    systemd.targets.hybrid-sleep.enable = false;
  };
}
