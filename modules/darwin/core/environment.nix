# System environment configuration
{ pkgs, ... }:
{
  programs.zsh.enable = true;

  environment = {
    systemPackages = [ pkgs.coreutils ];
    systemPath = [ "/opt/homebrew/bin" ];
    pathsToLink = [ "/Applications" ];
  };
}
