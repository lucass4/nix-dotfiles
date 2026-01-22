# Core nix-darwin system configuration
{ inputs, config, pkgs, ... }:
{
  programs.zsh.enable = true;
  environment = {
    systemPackages = [ pkgs.coreutils ];
    systemPath = [ "/opt/homebrew/bin" ];
    pathsToLink = [ "/Applications" ];
  };

  users.users."lucas".home = "/Users/lucas";

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    download-buffer-size = 67108864;
  };
}
