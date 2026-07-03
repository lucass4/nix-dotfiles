{ pkgs, ... }:
let
  helixPkg = pkgs.helix.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      # Provide runtime next to the binary for clean health checks
      ln -s $out/lib/runtime $out/bin/runtime

      # Terraform uses the HCL grammar but the upstream runtime is missing
      # per-language query stubs, so add ones that inherit from HCL to keep
      # syntax highlighting/textobjects/indents working for *.tf files.
      mkdir -p $out/lib/runtime/queries/terraform
      for query in folds highlights indents injections textobjects; do
        echo "; inherits: hcl" >"$out/lib/runtime/queries/terraform/''${query}.scm"
      done
    '';
  });

  # Web-family languages share the same shape: prettier formatter, ts LSP,
  # 2-space indent. Only the display name and prettier parser differ.
  prettierLang = { name, parser ? name, scope ? "source.${name}", server ? "typescript-language-server" }: {
    inherit name scope;
    language-servers = [ server ];
    formatter = {
      command = "${pkgs.prettier}/bin/prettier";
      args = [ "--parser" parser ];
    };
    auto-format = true;
    indent = { tab-width = 2; unit = "  "; };
  };
in
{
  programs.helix = {
    enable = true;
    package = helixPkg;

    settings = {
      theme = "catppuccin_mocha";

      editor = {
        scrolloff = 5;
        mouse = true;
        middle-click-paste = true;
        clipboard-provider = "pasteboard";
        scroll-lines = 3;
        line-number = "absolute";
        cursorline = true;
        cursorcolumn = false;
        gutters = [ "diagnostics" "spacer" "line-numbers" "spacer" "diff" ];
        auto-completion = true;
        auto-format = true;
        idle-timeout = 250;
        completion-timeout = 5;
        preview-completion-insert = true;
        completion-trigger-len = 2;
        completion-replace = true;
        auto-info = true;
        true-color = true;
        undercurl = false;
        rulers = [ 120 ];
        bufferline = "always";
        color-modes = true;
        text-width = 80;
        default-line-ending = "native";
        insert-final-newline = true;
        popup-border = "all";
        indent-heuristic = "hybrid";
        jump-label-alphabet = "abcdefghijklmnopqrstuvwxyz";

        statusline = {
          left = [ "mode" "spinner" ];
          center = [ "file-name" ];
          right = [
            "diagnostics"
            "selections"
            "position"
            "file-encoding"
            "file-line-ending"
            "file-type"
          ];
          separator = " ";
          mode = {
            normal = "NORMAL";
            insert = "INSERT";
            select = "SELECT";
          };
        };

        auto-pairs = true;

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        file-picker.hidden = false;

        indent-guides = {
          character = "╎";
          render = true;
        };
        lsp = {
          auto-signature-help = false;
          display-messages = true;
        };
      };

      keys.normal = {
        "C-r" = [
          ":write-all"
          ":insert-output scooter --no-stdin >/dev/tty"
          ":redraw"
          ":reload-all"
        ];
        "space".r = [ ":reload" ":redraw" ];
        "space".R = [ ":reload-all" ":redraw" ];
        "space".g = [
          ":write-all"
          ":insert-output lazygit >/dev/tty"
          ":redraw"
          ":reload-all"
        ];
        "space".w = ":w";
        "space".q = ":q";
        "space".f = [
          ":sh rm -f /tmp/files2open"
          ":set mouse false"
          ''
            :insert-output yazi "%{buffer_name}" --chooser-file=/tmp/files2open''
          ":redraw"
          ":set mouse true"
          ":open /tmp/files2open"
          "select_all"
          "split_selection_on_newline"
          "goto_file"
          ":buffer-close! /tmp/files2open"
        ];
        "Y" = "yank_to_clipboard";
        "p" = "paste_after";
        "P" = "paste_before";
      };
    };

    languages = {
      language = [
        {
          name = "rust";
          scope = "source.rust";
          file-types = [ "rs" ];
          language-servers = [ "rust-analyzer" ];
          auto-format = true;
          formatter = { command = "${pkgs.rustfmt}/bin/rustfmt"; };
        }
        {
          name = "python";
          scope = "source.python";
          file-types = [ "py" ];
          language-servers = [ "pyright" ];
          auto-format = true;
          formatter = { command = "${pkgs.black}/bin/black"; };
        }
        {
          name = "terraform";
          scope = "source.terraform";
          file-types = [ "tf" "tfvars" ];
          grammar = "hcl";
          language-servers = [ "terraform-ls" ];
          auto-format = true;
        }
        {
          name = "go";
          scope = "source.go";
          file-types = [ "go" ];
          language-servers = [ "gopls" ];
          auto-format = true;
          formatter = { command = "${pkgs.golines}/bin/golines"; };
        }
        {
          name = "bash";
          scope = "source.bash";
          file-types = [ "sh" ];
          language-servers = [ "bash-language-server" ];
          auto-format = true;
          formatter = { command = "${pkgs.shfmt}/bin/shfmt"; };
        }
        {
          name = "dockerfile";
          scope = "source.dockerfile";
          file-types = [ "Dockerfile" ];
          auto-format = true;
          language-servers = [ "dockerfile-language-server" ];
        }
        {
          name = "yaml";
          scope = "source.yaml";
          file-types = [ "yaml" "yml" ];
          language-servers = [ "yaml-language-server" ];
          auto-format = true;
          formatter = {
            command = "${pkgs.prettier}/bin/prettier";
            args = [ "--parser" "yaml" ];
          };
        }
        {
          name = "nix";
          scope = "source.nix";
          file-types = [ "nix" ];
          language-servers = [ "nil" ];
          auto-format = true;
          formatter = { command = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt"; };
        }
        (prettierLang { name = "html"; server = "vscode-html-language-server"; })
        (prettierLang { name = "css"; server = "vscode-css-language-server"; })
        (prettierLang { name = "typescript"; scope = "source.ts"; parser = "typescript"; })
        (prettierLang { name = "tsx"; scope = "source.tsx"; parser = "typescript"; })
        (prettierLang { name = "javascript"; scope = "source.js"; parser = "typescript"; })
        (prettierLang { name = "jsx"; scope = "source.jsx"; parser = "typescript"; })
      ];
    };

    extraPackages = with pkgs; [
      # Language Servers
      rust-analyzer
      pyright
      terraform-ls
      gopls
      bash-language-server
      dockerfile-language-server
      yaml-language-server
      nil
      vscode-langservers-extracted
      typescript-language-server

      # Formatters
      nixpkgs-fmt
      rustfmt
      black
      golines
      shfmt
      prettier
    ];
  };

  home.file.".config/helix/runtime".source = "${helixPkg}/lib/runtime";
}
