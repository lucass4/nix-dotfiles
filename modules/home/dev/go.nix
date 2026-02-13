# Go language tools and development environment
# Note: go binary is installed via Homebrew (required by m1-terraform-provider-helper)
{ pkgs, ... }:
{
  home.packages = with pkgs; [ golines gopls delve revive gotools golangci-lint ];
}
