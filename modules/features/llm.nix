{ inputs, ... }:
{
  flake.modules.nixos.llm = { pkgs, ... }: {
    nix.settings = {
      substituters = [ "https://numtide.cachix.org" ];
      trusted-public-keys = [ "numtide.cachix.org-1:B5erbLNksixY_bPqkS8c0ftMZ6xo8U7y2MoV92G13E0=" ];
    };
    environment.systemPackages =
      (with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
        claude-code
        opencode
      ])
      ++ (with pkgs; [ mcp-nixos ]);
  };
}
