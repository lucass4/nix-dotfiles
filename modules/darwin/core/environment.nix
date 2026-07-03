# System environment configuration
{ ... }:
{
  programs.zsh.enable = true;

  environment = {
    systemPath = [ "/opt/homebrew/bin" ];
    pathsToLink = [ "/Applications" ];
  };
}
