{ config, ... }:
{
  homeManagerModules.tmux = { pkgs, colors, ... }: {
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
