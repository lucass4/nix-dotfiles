# nix-darwin configuration entry point
{ ... }:
{
  imports = [
    # Core system configuration
    ./core/nix.nix
    ./core/environment.nix
    ./core/users.nix

    # macOS system settings
    ./system/defaults.nix
    ./system/ids.nix

    # Application-specific configs
    ./apps/firefox.nix

    # Package management
    ./homebrew.nix
  ];
}
