{ ... }:
{
  flake.modules.nixos.git = { pkgs, ... }: {
    programs.git = {
      enable = true;
      config = {
        init.defaultBranch = "main";
        pull.rebase = true;
        core.pager = "delta";
        interactive.diffFilter = "delta --color-only";
        delta = {
          navigate = true;
          dark = true;
        };
        merge.conflictstyle = "diff3";
        diff.colorMoved = "default";
      };
    };
    programs.lazygit = {
      enable = true;
      settings = {
        git.pagers = [
          { colorArg = "always"; pager = "delta --dark --paging=never"; }
        ];
      };
    };

    environment.sessionVariables.LAZYGIT_CONFIG_PATH = "/etc/xdg/lazygit/config.yml";

    environment.systemPackages = [ pkgs.delta ];
  };
}
