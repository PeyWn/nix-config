{ inputs, ... }:
{
  homeManagerModules.git = { pkgs, scheme, colors, ... }: let
    c = colors;
    p = scheme.palette;
    git-tidy-branches = pkgs.writeShellScriptBin "git-tidy-branches"
      (builtins.readFile ./scripts/git-tidy-branches);
    treehouse = inputs.treehouse.packages.${pkgs.stdenv.hostPlatform.system}.default;
  in {
    programs.git = {
      enable = true;
      settings = {
        init.defaultBranch = "main";
        core.pager = "delta";
        pull.rebase = true;
        merge.conflictstyle = "diff3";
        diff.colorMoved = "default";
      };
    };
    programs.delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true;
        side-by-side = false;
        minus-style = "syntax #${p.bg_red}";
        minus-emph-style = "syntax bold #${p.bg_red}";
        plus-style = "syntax #${p.bg_green}";
        plus-emph-style = "syntax bold #${p.bg_green}";
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
    };
    programs.lazygit = {
      enable = true;
      settings = {
        git.diffRenderers = [
          { colorArg = "always"; command = "delta --paging=never"; }
        ];
      };
    };

    home.packages = [ git-tidy-branches treehouse ];
  };
}
