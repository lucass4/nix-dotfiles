# Zsh shell configuration with plugins and aliases
{ config, pkgs, ... }:
{
  # Atuin - shell history with sync and search
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      ctrl_n_shortcuts = true;
      auto_sync = false;
      search_mode = "fuzzy";
      filter_mode_shell_up_key_binding = "directory";
      style = "compact";
      # Reference the Catppuccin theme
      theme.name = "catppuccin-mocha-mauve";
    };
  };

  # Atuin Catppuccin Mocha Mauve theme file
  home.file.".config/atuin/themes/catppuccin-mocha-mauve.toml".text = ''
    [theme]
    name = "catppuccin-mocha-mauve"

    [colors]
    AlertInfo = "#a6e3a1"
    AlertWarn = "#fab387"
    AlertError = "#f38ba8"
    Annotation = "#cba6f7"
    Base = "#cdd6f4"
    Guidance = "#9399b2"
    Important = "#f38ba8"
    Title = "#cba6f7"
  '';

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  # Zsh configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    # Autosuggestions and syntax highlighting
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # History settings
    history = {
      expireDuplicatesFirst = true;
      ignoreSpace = true;
      save = 100000; # Save 100,000 lines of history
    };

    envExtra = ''
      # Skip global compinit to speed up shell startup
      skip_global_compinit=1
    '';

    # Zsh completion initialization
    completionInit = ''
      # Only update compinit once each day
      autoload -Uz compinit
      for dump in ~/.zcompdump(N.mh+24); do
        compinit
      done
      compinit -C
    '';

    # Additional Zsh initialization commands
    initContent = ''
      # Setup zoxide
      eval "$(zoxide init zsh)"
      path+=${config.home.homeDirectory}/bin
      export GPG_TTY=$(tty)

      export SDKMAN_DIR="${config.home.homeDirectory}/.sdkman"
      [[ -s "${config.home.homeDirectory}/.sdkman/bin/sdkman-init.sh" ]] && source "${config.home.homeDirectory}/.sdkman/bin/sdkman-init.sh"

      # Auto-notification for long-running commands
      # Notify when commands take longer than 30 seconds
      AUTO_NOTIFY_THRESHOLD=30  # seconds
      AUTO_NOTIFY_IGNORE=("vim" "nvim" "hx" "helix" "tmux" "ssh" "top" "htop" "btm" "k9s" "lazydocker" "lazygit" "yazi")

      __auto_notify_preexec() {
        __auto_notify_start_time=$SECONDS
        __auto_notify_command=$1
      }

      __auto_notify_precmd() {
        local exit_code=$?
        if [ -n "$__auto_notify_start_time" ]; then
          local elapsed=$((SECONDS - __auto_notify_start_time))

          if [ $elapsed -ge $AUTO_NOTIFY_THRESHOLD ]; then
            # Extract the base command name
            local cmd_name=$(echo "$__auto_notify_command" | awk '{print $1}' | xargs basename)

            # Check if command should be ignored
            local should_ignore=0
            for ignore_cmd in "''${AUTO_NOTIFY_IGNORE[@]}"; do
              if [[ "$cmd_name" == "$ignore_cmd" ]]; then
                should_ignore=1
                break
              fi
            done

            if [ $should_ignore -eq 0 ]; then
              local message
              if [ $exit_code -eq 0 ]; then
                message="✓ Command finished (''${elapsed}s): $cmd_name"
              else
                message="✗ Command failed (''${elapsed}s, exit $exit_code): $cmd_name"
              fi

              terminal-notifier -title "Terminal" -message "$message" -group auto-notify -sound default
            fi
          fi

          unset __auto_notify_start_time
          unset __auto_notify_command
        fi
      }

      # Register hooks
      autoload -Uz add-zsh-hook
      add-zsh-hook preexec __auto_notify_preexec
      add-zsh-hook precmd __auto_notify_precmd

      # Manual notify function - send macOS notification when command completes
      # Usage: some-long-command; notify "Build finished"
      function notify() {
        local exit_code=$?
        local message="''${1:-Command finished}"
        local title="Terminal"

        if [ $exit_code -eq 0 ]; then
          terminal-notifier -title "$title" -message "✓ $message" -group terminal-notify -sound default
        else
          terminal-notifier -title "$title" -message "✗ $message (exit $exit_code)" -group terminal-notify -sound default
        fi
      }
    '';

    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.8.0";
          sha256 = "1lzrn0n4fxfcgg65v0qhnj7wnybybqzs4adz7xsrkgmcsr0ii8b7";
        };
      }
      {
        name = "just-completions";
        src = pkgs.runCommand "just-completions" { } ''
          mkdir -p $out
          ${pkgs.just}/bin/just --completions zsh > $out/_just
        '';
      }
    ];

    # Enable Oh My Zsh and configure plugins
    oh-my-zsh = {
      enable = true;
      plugins = [ "sudo" "vi-mode" "git" "extract" "command-not-found" ];
    };

    shellAliases = {
      # eza (better ls)
      l = "eza --icons --git -F";
      ll = "eza --icons --git -F -l";
      la = "eza --icons --git -F -a";
      lla = "eza --icons --git -F -la";
      lt = "eza --icons --git -F -T";
      llt = "eza --icons --git -F -l -T";

      # fd shortcuts (real `fd` stays unaliased)
      fdd = "fd -H -t d"; # directories only
      f = "fd -H"; # include hidden, ignore .gitignore

      # Docker / infra
      dc = "docker compose";
      tg = "terragrunt";
      tf = "terraform";

      # Misc
      assume = "source /opt/homebrew/bin/assume";
      fz = "fzf --preview 'bat --style=numbers --color=always --line-range :500 {}' --bind 'enter:become(hx {})'";
      findport = "sudo lsof -iTCP -sTCP:LISTEN -n -P | grep";
      clean-dsstore = "fd -H '\\.DS_Store$' -x rm";
      rpassword = "tr -dc A-Za-z0-9 </dev/urandom | head -c 20 | pbcopy";
    };
  };
}
