{ inputs, ... }:
{
  flake.modules.nixos.llm = { pkgs, ... }: {
    nix.settings = {
      extra-substituters = [ "https://cache.numtide.com" ];
      extra-trusted-public-keys = [ "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" ];
    };
    environment.systemPackages =
      let
        llmAgents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
        # llm-agents installs OpenCode 2 as `opencode2`; expose it under the upstream name.
        opencode2 = pkgs.runCommand "opencode2-alias" { } ''
          mkdir -p $out/bin
          ln -s ${llmAgents.opencode2}/bin/opencode2 $out/bin/opencode
        '';
      in
      [
        llmAgents.claude-code
        opencode2
      ]
      ++ (with pkgs; [
        mcp-nixos
        (python3.withPackages (ps: with ps; [
          requests
          httpx
          pyyaml
          rich
          pydantic
        ]))
      ]);
  };
}
