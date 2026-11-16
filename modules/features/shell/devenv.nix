{ ... }:
{
  flake.modules.nixos.shell = { username, ... }: {
    nix.settings = {
      trusted-users = [ username ];
      extra-substituters = [ "https://devenv.cachix.org" ];
      extra-trusted-public-keys = [
        "devenv.cachix.org-1:mIBmJ/WnH9Y3qhTrGMnYxoL1L1jkh1gbWtpFSEBi4Bc="
      ];
    };
  };
}
