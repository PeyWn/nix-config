{ inputs, ... }:
{
  flake.modules.nixos.git = { pkgs, config, ... }: let
    c = config.theme.colors;
    git-tidy-branches = pkgs.writeShellScriptBin "git-tidy-branches"
      (builtins.readFile ./scripts/git-tidy-branches);
  in {
    programs.git = {
      enable = true;
      config = {
        init.defaultBranch = "main";
        pull.rebase = true;
        core.pager = "delta";
        interactive.diffFilter = "delta --color-only";
        delta = {
          navigate = true;
          side-by-side = false;
          minus-style = "syntax #${c.base08}";
          minus-emph-style = "syntax bold #${c.base08}";
          plus-style = "syntax #${c.base0B}";
          plus-emph-style = "syntax bold #${c.base0B}";
          line-numbers-minus-style = "#${c.base08}";
          line-numbers-plus-style = "#${c.base0B}";
          line-numbers-zero-style = "#${c.base03}";
          hunk-header-decoration-style = "#${c.base0D} box";
          hunk-header-file-style = "#${c.base05}";
          hunk-header-line-number-style = "#${c.base03}";
          file-style = "#${c.base05}";
          file-decoration-style = "#${c.base0D} box";
          commit-style = "raw";
          commit-decoration-style = "#${c.base0C} box";
          whitespace-error-style = "reverse #${c.base08}";
        };
        merge.conflictstyle = "diff3";
        diff.colorMoved = "default";
      };
    };
    programs.lazygit = {
      enable = true;
      settings = {
        git.pagers = [
          { colorArg = "always"; pager = "delta --paging=never"; }
        ];
      };
    };

    environment.sessionVariables.LAZYGIT_CONFIG_PATH = "/etc/xdg/lazygit/config.yml";

    environment.systemPackages = [
      pkgs.delta
      git-tidy-branches
      inputs.treehouse.packages.${pkgs.system}.default
    ];
  };
}
