# nix-darwin configuration entry point
{ pkgs, ... }:
{
  imports = [
    ./core.nix
    ./brew.nix
    ./preferences.nix
  ];
}
