# Tmux terminal multiplexer configuration
{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;

    # Core settings
    aggressiveResize = true;
    baseIndex = 1;
    clock24 = true;
    disableConfirmationPrompt = true;
    escapeTime = 0; # Better vim/helix responsiveness
    historyLimit = 50000; # Increased scrollback
    keyMode = "vi";
    mouse = true;
    prefix = "C-a";
    terminal = "tmux-256color";

    # Plugins
    plugins = with pkgs.tmuxPlugins; [
      sensible # Better defaults
      yank # Enhanced copy/paste
      catppuccin # Match Helix theme
      cpu # CPU status module
      battery # Battery status module
      copycat # Regex searches
      extrakto # Fuzzy text extraction
      resurrect # Session restoration
      continuum # Automatic session saving
      prefix-highlight # Show prefix key
      tmux-fzf # Fuzzy finder integration
      vim-tmux-navigator # Seamless vim/tmux navigation
      pain-control # Better pane management
    ];

    extraConfig = ''
      # ── Plugin Configuration ─────────────────────────────────────────────────

      # tmux-fzf settings
      TMUX_FZF_LAUNCH_KEY="C-f"

      # Continuum - session persistence
      set -g @continuum-restore 'on'           # Auto-restore sessions on tmux start
      set -g @continuum-save-interval '15'     # Save session every 15 minutes

      # Catppuccin theme customization
      set -g @catppuccin_flavour 'mocha'       # Match Helix theme
      set -g @catppuccin_window_status_style "rounded"

      # Status bar layout using Catppuccin modules
      set -g status-left-length 100
      set -g status-right-length 100
      set -g status-left ""
      set -g status-right "#{E:@catppuccin_status_application}"
      set -agF status-right "#{E:@catppuccin_status_cpu}"
      set -ag status-right "#{E:@catppuccin_status_session}"
      set -ag status-right "#{E:@catppuccin_status_uptime}"
      set -agF status-right "#{E:@catppuccin_status_battery}"
      # Re-run status helpers after composing the line so placeholders expand
      run-shell "${pkgs.tmuxPlugins.cpu}/share/tmux-plugins/cpu/cpu.tmux"
      run-shell "${pkgs.tmuxPlugins.battery}/share/tmux-plugins/battery/battery.tmux"

      # ── General Settings ──────────────────────────────────────────────────────

      set -g detach-on-destroy off             # Switch to previous session when destroying
      set -g renumber-windows on               # Renumber windows when one is closed
      set -g status on                         # Enable status bar
      set -g status-interval 30                # Update status bar every 30 seconds
      set -g display-time 800                  # Display messages for 800ms
      set -g focus-events on                   # Enable focus events for better editor integration
      setw -g xterm-keys on                    # Enable xterm keys

      # Terminal settings
      set -g default-shell $SHELL
      set-option -sa terminal-overrides ",xterm*:Tc"
      set-option -ga terminal-features ",xterm-256color:RGB"

      # ── Copy Mode ──────────────────────────────────────────────────────────────

      bind Escape copy-mode
      bind p paste-buffer

      # Vi-style visual selection and copy
      bind-key -T copy-mode-vi v send -X begin-selection
      bind-key -T copy-mode-vi C-v send -X rectangle-toggle
      bind-key -T copy-mode-vi V send -X select-line
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"
      bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "pbcopy"
      bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "pbcopy"

      # ── Pane Management ───────────────────────────────────────────────────────

      # Pane splitting
      bind ! split-window -h -c "#{pane_current_path}"  # Split horizontally
      bind - split-window -v -c "#{pane_current_path}"  # Split vertically

      # Pane resizing (repeatable)
      bind-key -r H resize-pane -L "5"
      bind-key -r L resize-pane -R "5"
      bind-key -r J resize-pane -D "5"
      bind-key -r K resize-pane -U "5"

      # Pane swapping
      bind > swap-pane -D  # Swap pane down
      bind < swap-pane -U  # Swap pane up

      # ── Window Management ─────────────────────────────────────────────────────

      bind c new-window -c "#{pane_current_path}"  # New window in current path
      bind n new-window                            # New window in home
      bind Space last-window                       # Toggle between windows

      # Quick window navigation (Alt+H/L)
      bind -n M-H previous-window
      bind -n M-L next-window

      # ── Session Management ────────────────────────────────────────────────────

      bind BSpace switch-client -l  # Toggle between sessions

      # ── Layouts and Misc ──────────────────────────────────────────────────────

      bind t select-layout tiled  # Tiled layout

      # Kill commands
      bind x kill-pane            # Kill pane without confirmation
      bind k kill-window          # Kill window
      bind q kill-session         # Kill session

      # Reload config
      bind r source-file ~/.config/home-manager/tmux.conf \; display-message "Config reloaded!"

      # Buffer management
      bind b list-buffers   # List paste buffers
      bind P choose-buffer  # Choose buffer to paste

      # Send prefix to nested tmux session
      bind C-a send-prefix

      # Keep C-l for clearing the pane
      unbind -n C-l
      bind-key -n C-l send-keys C-l

      # Popup support for lazygit (if installed)
      bind g display-popup -E -w 90% -h 90% -d "#{pane_current_path}" lazygit
    '';
  };
}
