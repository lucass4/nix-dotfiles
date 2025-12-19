{ config, ... }: {
  # Set the primary user for the system.
  system.primaryUser = "lucas";

  # Resolve GID mismatch for the nixbld group as suggested by nix-darwin.
  ids.gids.nixbld = 350;

  # Keyboard settings
  system.keyboard = {
    enableKeyMapping = true;
    # Remap the Caps Lock key to Escape.
    remapCapsLockToEscape = true;
  };

  # macOS system-wide preferences using `system.defaults`.
  system.defaults = {
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

    # Dock-specific settings.
    dock = { autohide = true; };
  };

  system.activationScripts.setupFirefox = ''
    if [ -x /opt/homebrew/bin/defaultbrowser ]; then
      current=$(/opt/homebrew/bin/defaultbrowser 2>/dev/null | head -n 1 | tr -d '\r')
      if [ "$current" != "firefox" ]; then
        echo "Setting default browser to Firefox"
        su -l ${config.system.primaryUser} -c "/opt/homebrew/bin/defaultbrowser firefox" || \
          echo "Failed to set default browser; please set it manually."
      fi
    else
      echo "defaultbrowser CLI not found at /opt/homebrew/bin/defaultbrowser; skipping default browser configuration."
    fi

    firefox_resources="/Applications/Firefox.app/Contents/Resources"
    if [ -d "$firefox_resources" ]; then
      mkdir -p "$firefox_resources/distribution"
      cat > "$firefox_resources/distribution/policies.json" <<'EOF'
{
  "policies": {
    "Extensions": {
      "Install": [
        "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi",
        "https://addons.mozilla.org/firefox/downloads/latest/vimium-ff/latest.xpi"
      ]
    }
  }
}
EOF
      chmod 644 "$firefox_resources/distribution/policies.json"
      chown root:wheel "$firefox_resources/distribution/policies.json"
      echo "Configured Firefox policies to install 1Password and Vimium."
    else
      echo "Firefox.app not found at /Applications; skipping extension policy configuration."
    fi
  '';

  # This value should not be changed after the first build.
  # It's used for backwards compatibility and ensures smooth upgrades.
  system.stateVersion = 4;
}
