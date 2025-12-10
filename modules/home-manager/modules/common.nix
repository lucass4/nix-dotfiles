{ pkgs, ... }: {

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  home.packages = with pkgs;
    [
      # Shells and terminal utilities
      bash
      zsh
      reattach-to-user-namespace

      # Command replacements
      dust # Better du
      eza # Better ls
      neofetch # Fancy system + hardware info
      tealdeer # Fast tldr
      dogdns # Replacement for dig
      ripgrep # Replacement for grep
      fd # Replacement for find
      bat # Replacement for cat
      trash-cli # A better rm tool
      zoxide # Better jump, written in Rust

      # Git and version control tools
      git
      gh
      lazygit
      scooter
      git-crypt
      git-lfs
      hub
      cachix

      # File navigation and network tools
      fzf
      tree
      httpstat
      curlie
      wget
      speedtest-cli
      cloc

      # Compression tools
      zip
      pigz
      lz4

      # Kubernetes and Docker tools
      kubectx
      kubectl
      krew
      kubernetes-helm
      colima
      docker-client

      # Fonts
      powerline-fonts

      # Parsing and text manipulation
      jc
      # GHA local exec
      act

      # Database and productivity tools
      #pgcli
      page
      gnupg
      graphviz
      watch
      awscli2
      silver-searcher
      asdf-vm
      taskwarrior3
      taskwarrior-tui

      # Security and searching
      trufflehog
      sops
    ] ++ lib.optionals stdenv.isDarwin [
      coreutils # provides `dd` with --status=progress
    ];

  programs.dircolors = { enable = true; };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    enableNushellIntegration = false;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --exclude .git";
    fileWidgetCommand = "fd --type f"; # for when ctrl-t is pressed
  };
}
