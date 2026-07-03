{ pkgs, ... }:
{
  # Install Ghostty (using precompiled binary for faster installs)
  home.packages = [ pkgs.ghostty-bin ];

  # Ghostty configuration
  xdg.configFile."ghostty/config".text = ''
    # ==========================================
    # Ghostty Terminal Emulator Configuration
    # ==========================================
    # Ported from WezTerm configuration
    # Matches Catppuccin Mocha theme used system-wide (Helix, tmux)

    # ── Theme ─────────────────────────────────
    theme = Catppuccin Mocha

    # ── Font Configuration ────────────────────
    font-family = FiraCode Nerd Font
    font-size = 14

    # Font features (ligatures and stylistic sets)
    font-feature = +calt
    font-feature = +ss01
    font-feature = +ss02
    font-feature = +ss03
    font-feature = +ss05

    # ── Cursor ────────────────────────────────
    cursor-style = bar
    cursor-style-blink = false

    # ── Tab Bar ───────────────────────────────
    # Auto-hide tab bar when only one tab (matches WezTerm)
    window-show-tab-bar = auto

    # ── Shell Integration ─────────────────────
    # Launch zsh with tmux session (matches WezTerm behavior)
    command = ${pkgs.zsh}/bin/zsh -lc "${pkgs.tmux}/bin/tmux new-session -A -s main"

    # ── macOS Specific ────────────────────────
    macos-option-as-alt = true

    # ── Clipboard ─────────────────────────────
    clipboard-read = allow
    clipboard-write = allow
    clipboard-trim-trailing-spaces = true

    # ── Mouse ─────────────────────────────────
    mouse-hide-while-typing = true

    # ── Window ────────────────────────────────
    window-padding-x = 2
    window-padding-y = 2
  '';
}
