{ ... }:
{
  flake.modules.nixos.shell = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.ranger ];
  };

  flake.modules.homeManager.shell = { ... }: {
    home.file.".config/ranger/rc.conf".text = ''
      set preview_images false
      set preview_files true
    '';
  };
}
