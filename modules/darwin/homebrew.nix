# Homebrew package management configuration
{
  homebrew = {
    onActivation = {
      upgrade = true;
      cleanup = "zap";
      autoUpdate = true;
    };
    enable = true;

    taps = [
      "aws/tap"
      "common-fate/granted"
      "aquasecurity/trivy"
    ];

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
      "obsidian"
      "claude-code"
    ];

    masApps = { };

    brews = [
      # Networking and monitoring
      "trippy"

      # Development
      "pre-commit"
      "neovim"
      "node"
      "defaultbrowser"

      # CLI tools
      "ansiweather"
      "awk"
      "aws-iam-authenticator"
      "cookiecutter"
      "docker-compose"
      "docker-credential-helper"
      "eksctl"
      "goreleaser"
      "jq"
      "yq"
      "just"
      "pipx"
      "rtk"
      "helm@4"
      "pgcli"

      # GPG: headless commit signing via macOS Keychain.
      # Required by programs.git.signing.signByDefault — without it gpg-agent
      # falls back to pinentry-curses, which needs a TTY and hangs.
      "pinentry-mac"

      # Kubernetes
      "kubeseal"
      "kustomize"
      "vcluster"

      # AWS and infrastructure
      "granted"
      "steampipe"

      # Additional utilities
      "go@1.26" # Required by m1-terraform-provider-helper
      "trivy"
      "devspace"
      "copier"
      "gemini-cli"
      "skopeo"
      "argocd"
      "opencode"
      "can1357/tap/omp"
    ];
  };
}
