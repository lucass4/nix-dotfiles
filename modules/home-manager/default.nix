{ lib, manual, config, pkgs, ... }: {
  imports = [
    ./modules/wezterm.nix
    ./modules/zsh.nix
    ./modules/common.nix
    ./modules/git.nix
    ./modules/helix.nix
    ./modules/tmux.nix
    ./modules/yazi.nix
    ./modules/languages/docker.nix
    ./modules/languages/go.nix
    ./modules/languages/lua.nix
    ./modules/languages/markup.nix
    ./modules/languages/node.nix
    ./modules/languages/python.nix
    ./modules/languages/rust.nix
    ./modules/languages/terraform.nix
    ./modules/languages/nix.nix
    ./modules/languages/bash.nix
  ];

  home.stateVersion = "25.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  manual.manpages.enable = false;

  home.sessionVariables = {
    LANG = "en_CA.UTF-8";
    LC_ALL = "en_CA.UTF-8";
    KEYTIMEOUT = 1;
    EDITOR = "hx";
    VISUAL = "hx";
    GIT_EDITOR = "hx";
    LS_COLORS =
      "no=00:fi=00:di=01;34:ln=35;40:pi=40;33:so=01;35:bd=40;33;01:cd=40;33;01:or=01;05;37;41:mi=01;05;37;41:ex=01;32:*.cmd=01;32:*.exe=01;32:*.com=01;32:*.btm=01;32:*.bat=01;32:";
    LSCOLORS = "ExfxcxdxCxegedabagacad";
    FIGNORE = "*.o:~:Application Scripts:CVS:.git";
    TZ = "America/Vancouver";
    LESS =
      "--raw-control-chars -FXRadeqs -P--Less--?e?x(Next file: %x):(END).:?pB%pB%.";
    CLICOLOR = 1;
    CLICOLOR_FORCE = "yes";
    PAGER = "page -WO -q 90000";
    # Add colors to man pages
    MANPAGER = "less -R --use-color -Dd+r -Du+b +Gg -M -s";
    SYSTEMD_COLORS = "true";
    COLORTERM = "truecolor";
    FZF_CTRL_R_OPTS = "--sort --exact";
    BROWSER = "brave";
    TERMINAL = "alacritty";
    HOMEBREW_NO_AUTO_UPDATE = 1;
  };

}
