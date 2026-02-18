# General development tools and utilities
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # GitHub Actions local execution
    act

    # Runtime version manager (modern replacement for asdf)
    mise

    # Cloud tools
    awscli2
    ssm-session-manager-plugin # AWS Systems Manager Session Manager plugin

    # Security tools
    sops # Secrets management
    trufflehog # Secret scanning
  ];
}
