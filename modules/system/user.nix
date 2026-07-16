{ ... }:
{
  flake.modules.nixos.user = { pkgs, username, ... }: {
    users.users.${username} = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      shell = pkgs.zsh;
      initialPassword = "nixos";
    };
  };
}
