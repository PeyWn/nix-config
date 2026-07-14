{ ... }:
{
  flake.modules.nixos.userPeywn = { pkgs, ... }: {
    users.users.peywn = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      shell = pkgs.zsh;
      initialPassword = "nixos";
    };
  };
}
