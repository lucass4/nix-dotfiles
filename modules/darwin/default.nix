# nix-darwin configuration entry point
{ ... }:
{
  imports = [
    ./core.nix
    ./brew.nix
    ./preferences.nix
  ];
}
