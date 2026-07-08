{ ... }:
{
  flake.modules.nixos.home = { pkgs, username, hostname, ... }: {
    home-manager.users.${username} = {
      home.sessionPath = [ "$HOME/bin" ];
      home.packages = with pkgs; [ ripgrep fzf ];
      programs.zoxide.enable = true;
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        shellAliases = {
          ds = "devenv shell";
          dsc = "devenv shell -q '$@'";
          dj = "devenv shell -q 'just $@'";
          lg = "lazygit";
          clip = "/mnt/c/Windows/System32/clip.exe";
        };
        oh-my-zsh = {
          enable = true;
          plugins = [ "git" "fzf" "yarn" "npm" ];
        };
        initContent = ''
          rebuild() {
            local theme_flag=""
            local args=()
            while [[ $# -gt 0 ]]; do
              case $1 in
                --theme)
                  theme_flag="$2"; shift 2 ;;
                *) args+=("$1"); shift ;;
              esac
            done
            if [[ -n "$theme_flag" ]]; then
              sudo NIX_THEME="$theme_flag" nixos-rebuild switch --impure --flake "/home/nixos#${hostname}" "''${args[@]}"
            else
              sudo nixos-rebuild switch --flake "/home/nixos#${hostname}" "''${args[@]}"
            fi
          }

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
    };
  };
}
