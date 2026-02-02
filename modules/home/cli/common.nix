# Common CLI tools and modern replacements for standard Unix utilities
{ pkgs, lib, ... }:
let
  # Modern CLI replacements
  cliTools = with pkgs; [
    dust # Better du
    neofetch # Fancy system + hardware info
    tealdeer # Fast tldr
    fd # Replacement for find
    trash-cli # A better rm tool
    glow # Terminal markdown renderer
    bottom # Modern system monitor (btm command)
  ];

  # Shells and terminal utilities
  shellTools = with pkgs; [
    bash
    zsh
    reattach-to-user-namespace
  ];

  # File navigation and network tools
  fileAndNetTools = with pkgs; [
    tree
    httpstat
    curlie
    wget
    speedtest-cli
    cloc
  ];

  # Compression tools
  compressionTools = with pkgs; [
    zip
    pigz
    lz4
  ];

  # Git tools (git and gh are configured in git.nix)
  gitTools = with pkgs; [
    lazygit
    scooter
    git-crypt
    git-lfs
    hub
    cachix
    gitmux
  ];

  # Fonts
  fonts = with pkgs; [
    powerline-fonts
    nerd-fonts.fira-code
  ];

  # Parsing and text manipulation
  dataTools = with pkgs; [
    jc
  ];

  # Productivity tools
  productivityTools = with pkgs; [
    page
    gnupg
    graphviz
    watch
    silver-searcher
    taskwarrior3
    taskwarrior-tui
  ];

  # Platform-specific packages
  darwinPackages = lib.optionals pkgs.stdenv.isDarwin [
    pkgs.coreutils # provides `dd` with --status=progress
  ];
in
{
  # Program configurations
  programs = {
    # Direnv for automatic environment loading
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # Directory colors
    dircolors.enable = true;

    # Bat - better cat
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

    # Eza - better ls
    eza = {
      enable = true;
      enableZshIntegration = true;
      git = true;
      icons = "auto";
    };

    # Ripgrep - better grep
    ripgrep = {
      enable = true;
      arguments = [
        "--max-columns=150"
        "--max-columns-preview"
        "--smart-case"
      ];
    };

    # Zoxide - smart directory jumper
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    # FZF - fuzzy finder
    fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "fd --type f --hidden --exclude .git";
      fileWidgetCommand = "fd --type f"; # for when ctrl-t is pressed

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

  # All packages
  home.packages = cliTools
    ++ shellTools
    ++ fileAndNetTools
    ++ compressionTools
    ++ gitTools
    ++ fonts
    ++ dataTools
    ++ productivityTools
    ++ darwinPackages;
}
