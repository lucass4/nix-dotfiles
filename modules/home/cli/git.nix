# Git configuration with delta integration and common aliases
{ pkgs, lib, ... }:
{
  programs = {
    git = {
      enable = true;
      signing = {
        key = "56AE81F1E53DC9DC";
        signByDefault = true;
      };

      settings = {
        user = {
          name = "Lucas Sant' Anna";
          email = "76971778+lucass4@users.noreply.github.com";
        };

        alias = {
          # Basic aliases
          co = "checkout";
          br = "branch";
          st = "status -sb";
          lg = "log --graph --oneline --all";
          uncommit = "reset --soft HEAD^";
          amend = "commit --amend --no-edit";

          # Diff aliases
          d = "diff";
          ds = "diff --staged";
          dt = "difftool";
          dts = "difftool --staged";

          # Pretty log with graph
          l = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
          ll = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all";

          # Show files in a commit
          show-files = "show --name-only";

          # Show changes for a specific file
          history = "log -p --follow --";
        };

        pull.rebase = true;
        init.defaultBranch = "main";
        github.user = "lucass4";
        http.sslVerify = true;
        commit.verbose = true;

        diff = {
          algorithm = "histogram"; # Better than patience
          colorMoved = "default"; # Highlight moved code
          colorMovedWS = "allow-indentation-change";
        };

        push = {
          autoSetupRemote = true;
          default = "current";
          followTags = true;
        };

        merge.conflictStyle = "zdiff3";

        fetch = {
          prune = true;
          pruneTags = true;
        };

        rebase = {
          autoSquash = true;
          autoStash = true;
        };

        branch.sort = "-committerdate";
        rerere.enabled = true;
        maintenance.auto = true;
        help.autocorrect = "prompt";
        column.ui = "auto";
        log.date = "relative";

        core = {
          editor = "hx";
          # Suppress stderr warnings from delta
          pager = "${lib.getExe pkgs.delta} 2>/dev/null || ${lib.getExe pkgs.delta}";
          fileMode = false;
          ignorecase = false;
        };

        # Interactive diff with delta
        interactive.diffFilter = "${lib.getExe pkgs.delta} --color-only 2>/dev/null";

        url."git@github.com:".insteadOf = "https://github.com/";
      };
    };

    delta = {
      enable = true;
      options = {
        # Appearance
        syntax-theme = "Catppuccin Mocha";

        # Disable features that might cause issues
        features = "decorations";

        # Features
        navigate = true; # Use n and N to move between diff sections
        line-numbers = true;
        side-by-side = true;

        # Paging
        paging = "always";

        # Line numbers styling
        line-numbers-left-format = "{nm:>4}┊";
        line-numbers-right-format = "{np:>4}│";
        line-numbers-left-style = "blue";
        line-numbers-right-style = "blue";
        line-numbers-minus-style = "red";
        line-numbers-plus-style = "green";

        # File headers
        file-style = "bold yellow ul";
        file-decoration-style = "yellow box";

        # Hunk headers (function names)
        hunk-header-style = "file line-number syntax";
        hunk-header-decoration-style = "blue box";

        # Diff styling
        minus-style = "syntax #3f0001";
        minus-emph-style = "syntax #900009";
        plus-style = "syntax #002800";
        plus-emph-style = "syntax #006000";

        # Whitespace
        whitespace-error-style = "22 reverse";

        # Merge conflicts
        merge-conflict-begin-symbol = "▼";
        merge-conflict-end-symbol = "▲";
        merge-conflict-ours-diff-header-style = "yellow bold";
        merge-conflict-theirs-diff-header-style = "yellow bold italic";

        # Better word diffs
        word-diff-regex = "\\w+|[^\\w\\s]+";

        # Hyperlinks (if your terminal supports it)
        hyperlinks = true;
        hyperlinks-file-link-format = "file://{path}";
      };
    };

    # Alternative: difftastic - structural diff tool
    # Uncomment to try it instead of delta
    # git.extraConfig = {
    #   diff.tool = "difftastic";
    #   difftool.prompt = false;
    #   difftool.difftastic.cmd = "${lib.getExe pkgs.difftastic} \"$LOCAL\" \"$REMOTE\"";
    #   pager.difftool = true;
    # };

    gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
        editor = "hx";
        pager = "${lib.getExe pkgs.delta} --paging=always";
      };
    };
  };

  # Install difftastic as an option to try
  home.packages = with pkgs; [
    difftastic
  ];

}
