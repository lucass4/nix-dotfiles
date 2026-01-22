# Git configuration with delta integration and common aliases
{ pkgs, lib, ... }:
{
  programs.git = {
    enable = true;
    signing.key = "56AE81F1E53DC9DC";
    signing.signByDefault = true;

    settings = {
      user = {
        name = "Lucas Sant' Anna";
        email = "76971778+lucass4@users.noreply.github.com";
      };

      alias = {
        co = "checkout";
        br = "branch";
        st = "status -sb";
        lg = "log --graph --oneline --all";
        uncommit = "reset --soft HEAD^";
        amend = "commit --amend --no-edit";
      };

      pull.rebase = true;
      init.defaultBranch = "main";
      github.user = "lucass4";
      http.sslVerify = true;
      commit.verbose = true;
      diff.algorithm = "patience";
      diff.tool = "delta";

      push.autoSetupRemote = true;
      push.default = "current";
      push.followTags = true;

      merge.conflictStyle = "zdiff3";

      fetch.prune = true;
      fetch.pruneTags = true;

      rebase.autoSquash = true;
      rebase.autoStash = true;

      branch.sort = "-committerdate";

      rerere.enabled = true;

      maintenance.auto = true;

      help.autocorrect = "prompt";

      column.ui = "auto";
      log.date = "relative";

      core.editor = "hx";
      core.pager = lib.getExe pkgs.delta;
      core.fileMode = false;
      core.ignorecase = false;
      difftool.prompt = false;
      difftool."delta".cmd =
        "${lib.getExe pkgs.delta} --color-only --line-numbers --navigate --side-by-side \"$LOCAL\" \"$REMOTE\"";
      url."git@github.com:".insteadOf = "https://github.com/";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      side-by-side = true;
      syntax-theme = "Monokai Extended";
      line-numbers = true;
      navigate = true;
    };
  };

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      editor = "hx";
      pager = "${lib.getExe pkgs.delta} --paging=always";
    };
  };
}
