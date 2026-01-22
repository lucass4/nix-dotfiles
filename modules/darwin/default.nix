# nix-darwin configuration entry point
{ ... }:
{
  imports = [
    ./system.nix
    ./homebrew.nix
    ./preferences.nix
  ];
}
