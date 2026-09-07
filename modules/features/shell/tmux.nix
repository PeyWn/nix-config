{ ... }:
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
    environment.systemPackages = [ ts ];
  };
}
