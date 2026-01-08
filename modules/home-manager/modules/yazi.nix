{ config, pkgs, ... }:
let
  catppuccinMacchiato = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "flavors";
    rev = "4a1802a5add0f867b08d5890780c10dd1f051c36";
    sha256 = "1k0ricziqap8l3l3f9wbzybdgmmd2472f7kvz7al5grxp3n7vca6";
  };
in
{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
  };

  xdg.configFile."yazi/theme.toml".text = ''
    [flavor]
    dark = "catppuccin-macchiato"
  '';

  xdg.configFile."yazi/flavors/catppuccin-macchiato.yazi" = {
    source = "${catppuccinMacchiato}/catppuccin-macchiato.yazi";
    recursive = true;
  };
}
