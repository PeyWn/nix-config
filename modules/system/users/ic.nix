{ ... }:
{
  flake.modules.nixos.userIc = { pkgs, ... }: {
    users.users.bjorn = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      shell = pkgs.zsh;
      initialPassword = "nixos";
    };
  };
}
