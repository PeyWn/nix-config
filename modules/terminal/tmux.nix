{ config, ... }:
{
  flake.modules.nixos.tmux = { pkgs, ... }: {
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
        set -g status-position top
        set-option -g focus-events on

        # status bar
        set -g status-right "#(pomo)"
        set -g status-style "fg=#665c54"
        set -g status-left-style "fg=#928374"
        set -g status-bg default
        set -g status-interval 1
        set -g status-left ""

        set-window-option -g window-status-current-style fg=yellow

        setw -g pane-base-index 1
      '';
    };
  };
}
