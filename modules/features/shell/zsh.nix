{ ... }:
{
  flake.modules.nixos.shell = { pkgs, username, ... }: {
    programs.zsh.enable = true;
    environment.systemPackages = with pkgs; [ ripgrep fzf ];
    users.users.${username} = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      shell = pkgs.zsh;
    };
    security.sudo.wheelNeedsPassword = true;
  };

  flake.modules.homeManager.shell = { pkgs, hostname, ... }: {
    home.packages = with pkgs; [ ripgrep fzf ];
    programs.zoxide.enable = true;
    programs.starship.enable = true;
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      shellAliases = {
        rebuild = "sudo nixos-rebuild switch --flake /home/nixos#${hostname}";
        ds = "devenv shell";
        dsc = "devenv shell -q '$@'";
        dj = "devenv shell -q 'just $@'";
        lg = "lazygit";
      };
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "fzf" "yarn" "npm" ];
      };
      initContent = ''
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
}
