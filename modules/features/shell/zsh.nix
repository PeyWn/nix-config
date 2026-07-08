{ ... }:
{
  flake.modules.nixos.shell = { pkgs, username, ... }: {
    programs.zsh.enable = true;
    environment.systemPackages = with pkgs; [ ripgrep fzf ];
    users.users.${username} = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      shell = pkgs.zsh;
      initialPassword = "nixos";
    };
    security.sudo.wheelNeedsPassword = true;
  };
}
