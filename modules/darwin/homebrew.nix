# Homebrew package management configuration
{
  # Homebrew configuration
  homebrew = {
    onActivation = {
      upgrade = true;
      cleanup = "zap";
      autoUpdate = true;
    };
    enable = true;

    #cleanup = "zap"; # Options: "zap", "uninstall", "none"

    # Cask arguments
    caskArgs.no_quarantine = true;

    # Homebrew taps (no changes here)
    taps = [
      "homebrew/bundle"
      "homebrew/services"
      "koekeishiya/formulae"
      "fujiapple852/trippy"
      "kreuzwerker/taps"
      "metalbear-co/mirrord"
      "warrensbox/tap"
      "aws/tap"
      "common-fate/granted"
      "aquasecurity/trivy"
    ];

    # Homebrew casks (no changes here)
    casks = [
      "gpg-suite"
      "swiftdefaultappsprefpane"
      "firefox"
      "discord"
      "font-fira-code"
      "1password"
      "spotify"
      "raycast"
      "diffmerge"
      "visual-studio-code"
    ];

    # Homebrew MAS apps (no changes here)
    masApps = { };

    # Homebrew brews (no changes here)
    brews = [
      # Networking and monitoring tools
      "trippy"
      "eks-node-viewer"

      # Development and language tools
      "pre-commit"
      "lua"
      "luajit"
      "luv"
      "mpdecimal"
      "msgpack"
      "neovim"
      "node"
      "openjdk"
      "pcre2"
      "readline"
      "tree-sitter"
      "virtualenv"

      # Compression and libraries
      "lz4"
      "lzo"
      "m4"
      "nettle"
      "openssl@1.1"
      "pixman"
      "pkg-config"
      "unbound"
      "unibilium"
      "xorgproto"
      "xz"
      "zstd"
      "defaultbrowser"
      "libxcb"
      "libxdmcp"
      "libxext"
      "libxrender"
      "libyaml"

      # CLI tools
      "ansiweather"
      "awk"
      "aws-iam-authenticator"
      "cookiecutter"
      "docker-compose"
      "docker-credential-helper"
      "eksctl"
      "fontconfig"
      "goreleaser"
      "jq"
      "yq"
      "just"
      "pipx"

      # Kubernetes tools
      "kubeseal"
      "kustomize"
      "vcluster"

      # AWS and infrastructure tools
      "aws-iam-authenticator"
      "granted"
      "m1-terraform-provider-helper"
      "steampipe"

      # Additional utilities
      "bdw-gc"
      "ca-certificates"
      "go@1.26" # Required by m1-terraform-provider-helper
      "jpeg-turbo"
      "trivy"
      "devspace"
      "copier"
      "gemini-cli"
      "skopeo"
      "argocd"
      "opencode"
    ];
  };
}
