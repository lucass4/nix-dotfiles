{ config, pkgs, lib, libs, ... }: {
  programs.git = {
    enable = true;
    signing.key = "56AE81F1E53DC9DC";
    signing.signByDefault = true;

    settings = {
      user = {
        name = "Lucas Sant' Anna";
        email = "76971778+lucass4@users.noreply.github.com";
      };

      pull.rebase = true;
      init.defaultBranch = "main";
      github.user = "lucass4";
      http.sslVerify = true;
      commit.verbose = true;
      diff.algorithm = "patience";
      diff.tool = "delta";

      push.autoSetupRemote = true;

      core.editor = "hx";
      core.pager = "${pkgs.delta}/bin/delta";
      core.fileMode = false;
      core.ignorecase = false;
      difftool.prompt = false;
      difftool."delta".cmd =
        "${pkgs.delta}/bin/delta --color-only --line-numbers --navigate --side-by-side \"$LOCAL\" \"$REMOTE\"";
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
      pager = "${pkgs.delta}/bin/delta --paging=always";
    };
  };
}
