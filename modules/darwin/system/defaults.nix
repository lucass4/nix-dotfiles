# macOS system preferences and defaults
{ ... }:
{
  system = {
    # Set the primary user for the system.
    primaryUser = "lucas";

    # Keyboard settings
    keyboard = {
      enableKeyMapping = true;
      # Remap the Caps Lock key to Escape.
      remapCapsLockToEscape = true;
    };

    # macOS system-wide preferences
    defaults = {
      # Global domain settings for key repeat.
      NSGlobalDomain = {
        # Key repeat delay (lower is faster). Default is 15 (225ms).
        InitialKeyRepeat = 14; # (210ms)
        # Key repeat rate (lower is faster). Default is 2 (30ms).
        KeyRepeat = 1; # (15ms)
      };

      # Finder-specific settings.
      finder = {
        AppleShowAllExtensions = true;
        _FXShowPosixPathInTitle = true;
      };

      # Custom domain preferences.
      CustomUserPreferences."com.apple.desktopservices" = {
        # Prevent writing .DS_Store files on network/USB volumes.
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };

      # Dock-specific settings.
      dock = {
        autohide = true;
      };
    };

    # This value should not be changed after the first build.
    # It's used for backwards compatibility and ensures smooth upgrades.
    stateVersion = 4;
  };
}
