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
        git.pagings = [
          { colorArg = "always"; pager = "${pkgs.delta}/bin/delta --dark --paging=never"; }
        ];
      };
    };

    environment.systemPackages = [ pkgs.delta ];
  };
}
