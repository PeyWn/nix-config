{ ... }:
{
  flake.modules.nixos.shell = { pkgs, username, hostname, ... }: {
    programs.zsh = {
      enable = true;
      shellAliases.rebuild = "sudo nixos-rebuild switch --flake /home/nixos#${hostname}";
      shellAliases.ds = "devenv shell";
      shellAliases.dsc = "devenv shell -q '$@'";
      shellAliases.dj = "devenv shell -q 'just $@'";
      shellAliases.lg = "lazygit";
      ohMyZsh = {
        enable = true;
        plugins = [ "git" "fzf" "yarn" "npm" ];
      };
      interactiveShellInit = ''
        fz() {
          local dir
          IFS=$'\n' dir=($(zoxide query -l | fzf-tmux -h 30% -w 90% --query="$1" --multi --select-1 --exit-0 | rg --only-matching '/.*'))
          [[ -n "$dir" ]] && cd "''${dir[@]}"
        }

        fgsw() {
          local branch
          branch=($(git branch -a --format="%(refname:short)" | sed 's/origin\///' | grep -v 'HEAD' | grep -v "$(git rev-parse --abbrev-ref HEAD)" | awk '!seen[$0]++' | fzf-tmux -h 30 -w 90 --query="$1" --select-1 --exit-0))
          [[ -n "$branch" ]] && git switch $branch
        }

        fa() {
          local c
          IFS=$'\n' c=($(alias | fzf-tmux --tac --query="$1" --multi --select-1 --exit-0 | rg --only-matching '=.*' | rg --replace=''' '|='))
          [[ -n c ]] && eval $c
        }
      '';
    };
    programs.starship.enable = true;
    programs.zoxide.enable = true;
    environment.systemPackages = [ pkgs.ripgrep pkgs.tmux pkgs.fzf pkgs.just ];
    users.users.${username} = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      shell = pkgs.zsh;
    };
    security.sudo.wheelNeedsPassword = true;
  };
}
