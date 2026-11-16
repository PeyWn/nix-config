{ config, ... }:
{
  homeManagerModules.tmux = { pkgs, colors, ... }: let
    ts = pkgs.writeShellApplication {
      name = "ts";
      runtimeInputs = with pkgs; [ tmux fzf ];
      text = ''
        set -eu

        attach_or_switch() {
          if [ -n "''${TMUX:-}" ]; then
            tmux switch-client -t "$1"
          else
            tmux attach-session -t "$1"
          fi
        }

        new_session() {
          local name="''${1:-}"
          if [ -z "''${name:-}" ]; then
            echo -n "Session name: "
            read -r name
          fi
          [ -n "''${name:-}" ] || { echo "Session name required" >&2; exit 1; }
          if tmux has-session -t "$name" 2>/dev/null; then
            attach_or_switch "$name"
          else
            if [ -n "''${TMUX:-}" ]; then
              TMUX="" tmux new-session -d -s "$name"
              tmux switch-client -t "$name"
            else
              tmux new-session -s "$name"
            fi
          fi
        }

        case "''${1:-}" in
          new)
            new_session "''${2:-}"
            ;;
          "")
            result=$( (tmux list-sessions -F '#S' 2>/dev/null; echo "󰆍 New Session") | fzf-tmux -p --prompt="Session> " --exit-0 --select-1 --print-query)
            [ -n "''${result:-}" ] || exit 0
            query=$(echo "$result" | head -1)
            session=$(echo "$result" | tail -1)
            if [ "$session" = "󰆍 New Session" ]; then
              if [ -n "''${query:-}" ] && ! tmux has-session -t "$query" 2>/dev/null; then
                new_session "$query"
              else
                new_session
              fi
            else
              attach_or_switch "$session"
            fi
            ;;
          *)
            if tmux has-session -t "$1" 2>/dev/null; then
              attach_or_switch "$1"
            else
              new_session "$1"
            fi
            ;;
        esac
      '';
    };
  in {
    home.packages = [ ts ];
    programs.tmux = {
      enable = true;
      mouse = true;
      terminal = "tmux-256color";
      keyMode = "vi";
      escapeTime = 0;
      historyLimit = 25000;
      baseIndex = 0;
      aggressiveResize = true;
      focusEvents = true;
      clock24 = true;
      disableConfirmationPrompt = true;
      plugins = with pkgs.tmuxPlugins; [
        open
        urlview
        tmux-which-key
      ];
      extraConfig = ''
        ### Modified keys (Shift+Enter, ...) for Pi
        set -g extended-keys on
        set -g extended-keys-format csi-u

        ### True Color Support
        set -ga terminal-overrides ",*256col*:Tc"
        set -g set-clipboard on
        set -g status-position top
        set -g status-keys emacs

        set -g automatic-rename on
        set -g automatic-rename-format "#{pane_current_command}"

        set -g status-right "#(pomo)"
        set -g status-style "fg=#${colors.base03}"
        set -g status-left-style "fg=#${colors.base04}"
        set -g status-bg default
        set -g status-interval 1
        set -g status-left ""

        set-window-option -g window-status-current-style "fg=#${colors.base0A}"
        setw -g pane-base-index 1
      '';
    };
  };
}
