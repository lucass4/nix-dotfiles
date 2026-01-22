{ pkgs, ... }: {
  home.packages = with pkgs; [
    # GitHub Actions local execution
    act

    # Runtime version manager
    asdf-vm

    # Cloud tools
    awscli2

    # Security tools
    sops # Secrets management
    trufflehog # Secret scanning
  ];
}
