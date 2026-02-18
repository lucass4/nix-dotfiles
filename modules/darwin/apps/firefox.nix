# Firefox configuration and policies
{ config, ... }:
{
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
}
