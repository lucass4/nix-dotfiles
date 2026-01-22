# GID and UID management
{ ... }:
{
  # Resolve GID mismatch for the nixbld group as suggested by nix-darwin.
  ids.gids.nixbld = 350;
}
