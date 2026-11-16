{ inputs, ... }:
{
  homeManagerModules.llm = { pkgs, ... }:
  let
    quick = {
      model = "chatgpt-subscription/gpt-6-luna";
      reasoning = "low";
    };
    normal = {
      model = "chatgpt-subscription/gpt-6.1-terra";
      reasoning = "medium";
    };
    coding = {
      model = "chatgpt-subscription/gpt-6.1-sol";
      reasoning = "medium";
    };
    heavy = {
      model = "chatgpt-subscription/gpt-6-astra";
      reasoning = "high";
    };
    economical = {
      model = "opencode-go/mimo-v2.6-pro";
      reasoning = "medium";
    };
    prose = {
      model = "opencode-go/glm-5.3";
      reasoning = "medium";
    };
  in
  {
    home.sessionVariables.OMO_RUNTIME = "bun";
    home.file.".omo/omo.jsonc".text = builtins.toJSON {
      "$schema" = "https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/dev/assets/omo.schema.json";

      model_profile = "economy";
      model_profiles = {
        economy = {
          display_name = "Economy";
          models = [ normal ];
        };
        heavy = {
          display_name = "Heavy reasoning";
          models = [ heavy ];
        };
      };

      # A singleton round-robin chain excludes OmO's built-in retry models.
      categories = builtins.mapAttrs (_: model: {
        models = [ model ];
        models_distribution = "round_robin";
      }) {
        inherit quick;
        writing = prose;
        unspecified-low = economical;
        unspecified-high = coding;
        deep-low = coding;
        visual-engineering = coding;
        artistry = coding;
        architect = heavy;
        deep-high = heavy;
        ultrabrain = heavy;
      };

      agents = {
        explore = quick;
        librarian = quick;
        plan-consultant = coding;
        plan-reviewer = coding;
        omo-native-code-reviewer = coding;
        omo-native-gate-reviewer = coding;
        omo-native-qa-executor = normal;
      };
    };
    home.packages =
      let
        llmAgents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
        # llm-agents installs OpenCode 2 as `opencode2`; expose it under the upstream name.
        opencode2 = pkgs.runCommand "opencode2-alias" { } ''
          mkdir -p $out/bin
          ln -s ${llmAgents.opencode2}/bin/opencode2 $out/bin/opencode
        '';
      in
      [
        llmAgents.omo-ai
        llmAgents.claude-code
        opencode2
      ]
      ++ (with pkgs; [
        bun
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
