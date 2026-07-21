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
  in {
    environment.systemPackages = [ ts ];
  };
}
