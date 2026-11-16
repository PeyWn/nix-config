{ ... }:
{
  homeManagerModules.tools = { pkgs, ... }: {
    home.packages = with pkgs; [ just bat htop btop gtop glow devenv ];
  };
}
