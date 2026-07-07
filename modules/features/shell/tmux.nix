{ config, ... }:
{
  flake.modules.nixos.shell = { pkgs, ... }: let
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
          *)
            session=$( (tmux list-sessions -F '#S' 2>/dev/null; echo "󰆍 New Session") | fzf-tmux -p --prompt="Session> " --exit-0)
            [ -n "''${session:-}" ] || exit 0
            if [ "$session" = "󰆍 New Session" ]; then
              new_session
            else
              attach_or_switch "$session"
            fi
            ;;
        esac
      '';
    };
    tmux-window-status = pkgs.writeShellApplication {
      name = "tmux-window-status";
      runtimeInputs = with pkgs; [ procps gawk coreutils ];
      text = ''
      set -eu
      PID="$1"
      [ -n "$PID" ] || exit 0
      stat_line=$(cat /proc/"$PID"/stat 2>/dev/null)
      [ -n "$stat_line" ] || exit 0
      fields="''${stat_line##*)}"
      read -r _ _ pgrp _ _ tpgid _ <<< "$fields"
      [ "$tpgid" != "$pgrp" ] || exit 0
      [ "$tpgid" -gt 0 ] 2>/dev/null || exit 0
      running=false
      stopped=false
      found_any=false
      for p in $(pgrep -g "$tpgid" 2>/dev/null); do
        found_any=true
        s=$(awk '{print $3}' /proc/"$p"/stat 2>/dev/null)
        case "$s" in
          R) running=true; break ;;
          T) stopped=true ;;
        esac
      done
      $found_any || exit 0

      STATE_DIR="/tmp/tmux-window-status"
      mkdir -p "$STATE_DIR"
      STATEFILE="$STATE_DIR/$tpgid"

      if $running; then
        rm -f "$STATEFILE"
        echo -n "#[fg=green]● "
      elif $stopped; then
        rm -f "$STATEFILE"
        echo -n "#[fg=red]● "
      else
        # All foreground processes are sleeping (S/D state).
        # Track how long the group has been continuously asleep.
        # Green when active/recently running (<THRESHOLD),
        # cyan when sustained sleep suggests waiting for user input.
        now=$(date +%s)
        THRESHOLD=10
        if [ -f "$STATEFILE" ]; then
          start=$(cat "$STATEFILE")
          if [ $((now - start)) -ge "$THRESHOLD" ]; then
            echo -n "#[fg=cyan]● "
          else
            echo -n "#[fg=green]● "
          fi
        else
          echo "$now" > "$STATEFILE"
          echo -n "#[fg=green]● "
        fi
      fi

      # Remove state files for dead process groups
      for f in "$STATE_DIR"/*; do
        t=$(basename "$f")
        pgrep -g "$t" >/dev/null 2>&1 || rm -f "$f"
      done
    '';
    };
  in {
    environment.systemPackages = [ ts ];
    programs.tmux = {
      enable = true;
      historyLimit = 25000;
      escapeTime = 10;
      baseIndex = 1;
      terminal = "screen-256color";
      keyMode = "vi";
      plugins = with pkgs.tmuxPlugins; [
        open
        urlview
      ];
      extraConfig = ''
        set -g mouse on
        set -g set-clipboard on
        set -g status-position top
        set-option -g focus-events on

        # auto-rename windows to current command
        set -g automatic-rename on
        set -g automatic-rename-format "#{pane_current_command}"

        # status bar
        set -g status-right "#(pomo)"
        set -g status-style "fg=#665c54"
        set -g status-left-style "fg=#928374"
        set -g status-bg default
        set -g status-interval 1
        set -g status-left ""

        set-window-option -g window-status-current-style fg=yellow
        set -g window-status-format "#(${tmux-window-status}/bin/tmux-window-status #{pane_pid})#[fg=#928374]#I:#W"
        set -g window-status-current-format "#(${tmux-window-status}/bin/tmux-window-status #{pane_pid})#[fg=yellow]#I:#W"

        setw -g pane-base-index 1
      '';
    };
  };
}
