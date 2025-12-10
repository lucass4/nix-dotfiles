{ pkgs, ... }: {
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require("wezterm")

      local config = wezterm.config_builder()

      local palette = {
        background = "#000000",
        foreground = "#e0def4",
        selection_bg = "#403d52",
        selection_fg = "#e0def4",
        cursor = "#e0def4",
        tab = "#191724",
        tab_active = "#26233a",
        black = "#26233a",
        red = "#eb6f92",
        green = "#31748f",
        yellow = "#f6c177",
        blue = "#9ccfd8",
        magenta = "#c4a7e7",
        cyan = "#ebbcba",
        white = "#e0def4",
        bright_black = "#6e6a86",
        bright_red = "#eb6f92",
        bright_green = "#31748f",
        bright_yellow = "#f6c177",
        bright_blue = "#9ccfd8",
        bright_magenta = "#c4a7e7",
        bright_cyan = "#ebbcba",
        bright_white = "#e0def4",
      }

      config.colors = {
        foreground = palette.foreground,
        background = palette.background,
        cursor_bg = palette.cursor,
        cursor_border = palette.cursor,
        cursor_fg = palette.background,
        selection_bg = palette.selection_bg,
        selection_fg = palette.selection_fg,
        ansi = {
          palette.black,
          palette.red,
          palette.green,
          palette.yellow,
          palette.blue,
          palette.magenta,
          palette.cyan,
          palette.white,
        },
        brights = {
          palette.bright_black,
          palette.bright_red,
          palette.bright_green,
          palette.bright_yellow,
          palette.bright_blue,
          palette.bright_magenta,
          palette.bright_cyan,
          palette.bright_white,
        },
        tab_bar = {
          background = palette.tab,
          active_tab = {
            bg_color = palette.tab_active,
            fg_color = palette.white,
          },
          inactive_tab = {
            bg_color = palette.tab,
            fg_color = palette.bright_black,
          },
          new_tab = {
            bg_color = palette.tab,
            fg_color = palette.blue,
          },
        },
      }

      config.font = wezterm.font_with_fallback({
        {
          family = "Liga SFMono Nerd Font",
          harfbuzz_features = { "ss01", "ss02", "ss04", "ss05" },
        },
      })

      config.font_size = 15.0
      config.default_prog = {
        "${pkgs.zsh}/bin/zsh",
        "-lc",
        "${pkgs.tmux}/bin/tmux new-session -A -s main",
      }
      config.window_background_opacity = 0.85
      config.macos_window_background_blur = 20
      config.default_cursor_style = "SteadyBar"
      config.cursor_blink_rate = 0
      config.use_fancy_tab_bar = false
      config.hide_tab_bar_if_only_one_tab = true

      return config
    '';
  };
}
