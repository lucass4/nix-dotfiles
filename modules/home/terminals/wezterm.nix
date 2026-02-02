{ pkgs, ... }: {
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require("wezterm")

      local config = wezterm.config_builder()

      config.color_scheme = "Catppuccin Mocha"

      config.font = wezterm.font_with_fallback({
        {
          family = "FiraCode Nerd Font",
          harfbuzz_features = { "calt", "ss01", "ss02", "ss03", "ss05" },
        },
      })

      config.font_size = 14.0
      config.default_prog = {
        "${pkgs.zsh}/bin/zsh",
        "-lc",
        "${pkgs.tmux}/bin/tmux new-session -A -s main",
      }
      config.window_background_opacity = 1.0
      config.macos_window_background_blur = 0
      config.default_cursor_style = "SteadyBar"
      config.cursor_blink_rate = 0
      config.use_fancy_tab_bar = false
      config.hide_tab_bar_if_only_one_tab = true

      return config
    '';
  };
}
