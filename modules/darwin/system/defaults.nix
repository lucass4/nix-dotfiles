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
      # Global domain settings
      NSGlobalDomain = {
        # Key repeat settings (faster than defaults)
        InitialKeyRepeat = 14; # Delay before repeat (210ms)
        KeyRepeat = 1; # Key repeat rate (15ms)

        # Disable press-and-hold for keys in favor of key repeat
        ApplePressAndHoldEnabled = false;

        # Appearance
        AppleInterfaceStyle = "Dark"; # Dark mode

        # Disable auto-correct and auto-capitalization
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;

        # Expand save and print panels by default
        NSNavPanelExpandedStateForSaveMode = true;
        PMPrintingExpandedStateForPrint = true;
      };

      # Finder settings
      finder = {
        AppleShowAllExtensions = true;
        _FXShowPosixPathInTitle = true;
        FXPreferredViewStyle = "Nlsv"; # List view by default
        ShowPathbar = true;
        ShowStatusBar = true;
        FXEnableExtensionChangeWarning = false; # Disable extension change warning
      };

      # Dock settings
      dock = {
        autohide = true;
        show-recents = false; # Don't show recent applications

        # Hot corners
        wvous-tl-corner = 2; # Top-left: Mission Control
        wvous-tr-corner = 4; # Top-right: Desktop
        wvous-bl-corner = 3; # Bottom-left: Application Windows
        wvous-br-corner = 11; # Bottom-right: Launchpad
      };

      # Menu bar clock settings
      menuExtraClock = {
        ShowSeconds = true;
        ShowDayOfWeek = true;
        ShowAMPM = true;
        ShowDate = 0; # 0 = never, 1 = when space allows, 2 = always
      };

      # Custom domain preferences
      CustomUserPreferences = {
        # Desktop Services - prevent .DS_Store on network/USB
        "com.apple.desktopservices" = {
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };

        # Screenshot settings
        "com.apple.screencapture" = {
          location = "~/Pictures/Screenshots";
          type = "png";
          disable-shadow = false;
        };
      };
    };

    # This value should not be changed after the first build.
    # It's used for backwards compatibility and ensures smooth upgrades.
    stateVersion = 4;
  };
}
