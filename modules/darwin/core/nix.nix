# Nix daemon and experimental features configuration
{ ... }:
{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    download-buffer-size = 67108864;
  };
}
