
{ ... }:
{
  flake.modules.nixos.devops = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ k9s kubectl kubelogin-oidc ];
  };
}
