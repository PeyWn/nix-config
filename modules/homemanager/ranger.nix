{ ... }:
{
  flake.modules.nixos.home = { username, ... }: {
    home-manager.users.${username}.home.file.".config/ranger/rc.conf".text = ''
      set preview_images false
      set preview_files true
    '';
  };
}
