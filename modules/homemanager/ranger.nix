{ ... }:
{
  homeManagerModules.ranger = { pkgs, ... }: {
    home.packages = [ pkgs.ranger pkgs.bat ];
    home.file.".config/ranger/rc.conf".text = ''
      set preview_images false
      set preview_files true
      set preview_files_method bat
    '';
  };
}
