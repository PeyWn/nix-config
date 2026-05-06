{ inputs, ... }:
{
  flake.modules.nixos.llm = { pkgs, ... }: {
    environment.systemPackages =
      (with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
        claude-code
        opencode
      ])
      ++ (with pkgs; [ mcp-nixos ]);
  };
}
