# Common CLI tools and modern replacements for standard Unix utilities
{ pkgs, lib, ... }:
{
  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    dircolors.enable = true;

    bat = {
      enable = true;
      config = {
        theme = "Catppuccin Mocha";
        pager = "less -FR";
      };
      themes = {
        "Catppuccin Mocha" = {
          src = pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "bat";
            rev = "d3feec47b16a8e99eabb34cdfbaa115541d374fc";
            sha256 = "sha256-s0CHTihXlBMCKmbBBb8dUhfgOOQu9PBCQ+uviy7o47w=";
          };
          file = "themes/Catppuccin Mocha.tmTheme";
        };
      };
    };

    eza = {
      enable = true;
      enableZshIntegration = true;
      git = true;
      icons = "auto";
    };

    ripgrep = {
      enable = true;
      arguments = [
        "--max-columns=150"
        "--max-columns-preview"
        "--smart-case"
      ];
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "fd --type f --hidden --exclude .git";
      fileWidget.command = "fd --type f";
      historyWidget.command = ""; # Atuin owns Ctrl-R

      # Catppuccin Mocha theme
      colors = {
        bg = "#1e1e2e";
        "bg+" = "#313244";
        fg = "#cdd6f4";
        "fg+" = "#cdd6f4";
        header = "#f38ba8";
        hl = "#f9e2af";
        "hl+" = "#f9e2af";
        info = "#cba6f7";
        marker = "#f5e0dc";
        pointer = "#f5e0dc";
        prompt = "#cba6f7";
        spinner = "#f5e0dc";
      };
    };
  };

  home.packages = with pkgs; [
    dust
    fastfetch
    tealdeer
    fd
    trash-cli
    glow
    bottom
    terminal-notifier
    reattach-to-user-namespace
    tree
    httpstat
    curlie
    wget
    speedtest-cli
    cloc
    zip
    pigz
    lz4
    lazygit
    scooter
    git-crypt
    git-lfs
    cachix
    gitmux
    nerd-fonts.fira-code
    jc
    page
    gnupg
    graphviz
    d2
    watch
    silver-searcher-ng
    taskwarrior3
    taskwarrior-tui
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    coreutils # provides `dd` with --status=progress
  ];
}
