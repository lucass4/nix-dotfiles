{ pkgs, ... }:
let
  catppuccinTheme = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "yazi";
    rev = "fc69d6472d29b823c4980d23186c9c120a0ad32c";
    sha256 = "sha256-Og33IGS9pTim6LEH33CO102wpGnPomiperFbqfgrJjw=";
  };
in
{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
  };

  # Install Catppuccin Mocha theme with blue accent
  xdg.configFile."yazi/theme.toml".source = "${catppuccinTheme}/themes/mocha/catppuccin-mocha-blue.toml";

  # Main yazi configuration
  xdg.configFile."yazi/yazi.toml".text = ''
    [manager]
    show_hidden = false
    sort_by = "natural"
    sort_dir_first = true
    linemode = "size"

    [preview]
    max_width = 1000
    max_height = 1000
    image_filter = "lanczos3"
    image_quality = 90
  '';

  # Keybindings
  xdg.configFile."yazi/keymap.toml".text = ''
    [manager]
    prepend_keymap = [
      { on = [ "<C-f>" ], run = "plugin fzf", desc = "Fuzzy find files/directories" },
      { on = [ "z" ], run = "plugin --sync zoxide", desc = "Jump to a directory using zoxide" },
    ]
  '';
}
