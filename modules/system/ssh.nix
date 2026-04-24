{ ... }:
{
  flake.modules.nixos.ssh = {
    programs.ssh = {
      startAgent = true;
      extraConfig = ''
        Host ssh.dev.azure.com vs-ssh.visualstudio.com
          User git
          IdentityFile ~/.ssh/id_rsa
          AddKeysToAgent 8h
          KexAlgorithms diffie-hellman-group14-sha256,diffie-hellman-group16-sha512,diffie-hellman-group-exchange-sha256,diffie-hellman-group18-sha512

        Host github.com
          User git
          IdentityFile ~/.ssh/id_private
          AddKeysToAgent 8h

        Host *
          KexAlgorithms mlkem768x25519-sha256,curve25519-sha256@libssh.org,curve25519-sha256
      '';
    };
  };
}
