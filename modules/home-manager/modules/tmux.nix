{ config, xdg, lib, pkgs, ... }: {
  programs.tmux = {
    enable = true;
    aggressiveResize = true;
    baseIndex = 1;
    clock24 = true;
    disableConfirmationPrompt = true;
    keyMode = "vi";
    prefix = "C-a";
    terminal = "screen-256color";
    plugins = with pkgs.tmuxPlugins; [
      copycat
      extrakto
      nord
      resurrect
      continuum
      prefix-highlight
      tmux-fzf
      vim-tmux-navigator
    ];

    extraConfig = ''
      TMUX_FZF_LAUNCH_KEY="C-f"

      # Session persistence settings
      set -g @continuum-restore 'on'           # automatically restore sessions on tmux start
      set -g @continuum-save-interval '15'     # save session every 15 minutes

      set -g detach-on-destroy off             # When destory switch to the prev session
      set -ga terminal-overrides ",xterm-256color:Tc"
      set -g default-shell $SHELL              # use default shell
      set -g renumber-windows on               # renumber windows when a window is closed
      set -g status on                         # status bar on
      set -g status-interval 30                # update status bar every 30 seconds
      set -g history-limit 5000                # scrollback buffer
      set -g display-time 800
      set -g status-left-length 30
      set -g base-index 1
      set -g pane-base-index 1
      set -g default-terminal "screen-256color"  # with 256 color capability
      set -g mouse on                          # enable mouse mode
      set -g status-left-length 50
      ## General Settings
      setw -g xterm-keys on                     # enable xterm keys
      set-option -sg escape-time 0 # change the escape time in tmux to zero, improves vim responsiveness

      ## Copy and Paste
      bind Escape copy-mode
      bind p paste-buffer
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"
      bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "pbcopy"
      bind -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "pbcopy"
      # ── Pane settings ───────────────────────────────────────────────────────────

      # Pane resizing {{{
        bind-key -r H resize-pane -L "5"
        bind-key -r L resize-pane -R "5"
        bind-key -r J resize-pane -D "5"
        bind-key -r K resize-pane -U "5"
      # }}}

      ## More key binds
      bind ! split-window -h -c "#{pane_current_path}"          # split horizontally
      bind - split-window -v -c "#{pane_current_path}"          # split vertically
      bind n new-window                                         # open new window
      bind x kill-pane                                          # kill pane without confirmation
      bind k kill-window                                        # kill window
      bind q kill-session                                       # kill session
      bind r source-file ~/.config/tmux/tmux.conf               # reload tmux config
      bind t select-layout tiled                                # tiled layout

      # Buffers
      bind b list-buffers  # list paste buffers
      bind p paste-buffer  # paste from the top paste buffer
      bind P choose-buffer # choose which buffer to paste from

      # Keep C-l for clearing the pane instead of vim-tmux-navigator's pane move
      unbind -n C-l
      bind-key -n C-l send-keys C-l
    '';
  };
}
