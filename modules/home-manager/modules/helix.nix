{ pkgs, inputs, ... }: {
  programs.helix = {
    enable = true;

    # The catppuccin-mocha theme, provided by the helix-themes flake
    themes = inputs.helix-themes.outputs.themes;

    settings = {
      theme = "catppuccin_mocha";

      editor = {
        # Number of inlines of padding around the edge of the screen when scrolling
        scrolloff = 5;

        # Enable mouse mode
        mouse = true;

        # Middle click paste support
        middle-click-paste = true;

        # Number of lines to scroll per scroll wheel step
        scroll-lines = 3;
        # shell = []

        # Line number display: absolute simply shows each line's number, while relative shows the distance from the current line# .
        # When unfocused or in insert mode, relative will still show absolute line numbers
        line-number = "absolute";

        # Highlight all lines with a cursor
        cursorline = true;

        # Highlight all columns with a cursor
        cursorcolumn = false;

        # Gutters to display: Available are diagnostics and diff and line-numbers and spacer, note that diagnostics also includes other features like breakpoints, 1-width padding will be inserted if gutters is non-empty
        gutters = [ "diagnostics" "spacer" "line-numbers" "spacer" "diff" ];

        # Enable automatic pop up of auto-completion
        auto-completion = true;

        # Enable automatic formatting on save
        auto-format = true;

        # Time in milliseconds since last keypress before idle timers trigger.
        idle-timeout = 250;

        # Time in milliseconds after typing a word character before completions are shown, set to 5 for instant.
        completion-timeout = 5;

        # Whether to apply completion item instantly when selected
        preview-completion-insert = true;

        # The min-length of word under cursor to trigger autocompletion
        completion-trigger-len = 2;

        # Set to true to make completions always replace the entire word and not just the part before the cursor
        completion-replace = true;

        # Whether to display info boxes
        auto-info = true;

        # Set to true to override automatic detection of terminal truecolor support in the event of a false negative
        true-color = true;

        # Set to true to override automatic detection of terminal undercurl support in the event of a false negative
        undercurl = false;

        # List of column positions at which to display the rulers.
        # Can be overridden by language specific rulers in languages.toml file
        rulers = [ 120 ];

        # Renders a line at the top of the editor displaying open buffers.
        # Can be always, never or multiple (only shown if more than one buffer is in use)
        bufferline = "always";

        # Whether to color the mode indicator with different colors depending on the mode itself
        color-modes = true;

        # Maximum line length. Used for the :reflow command and soft-wrapping if soft-wrap.wrap-at-text-width is set
        text-width = 80;

        # workspace-lsp-roots = []

        # The line ending to use for new documents.
        # Can be native, lf, crlf, ff, cr or nel. native uses the platform's native line ending (crlf on Windows, otherwise lf).
        default-line-ending = "native";

        # Whether to automatically insert a trailing line-ending on write if missing
        insert-final-newline = true;

        # Draw border around popup, menu, all, or none
        popup-border = "all";

        # How the indentation for a newly inserted line is computed: simple just copies the indentation level from the previous line, tree-sitter computes the indentation based on the syntax tree and hybrid combines both approaches.
        # If the chosen heuristic is not available, a different one will be used as a fallback (the fallback order being hybrid -> tree-sitter -> simple).
        indent-heuristic = "hybrid";

        # The characters that are used to generate two character jump labels.
        # Characters at the start of the alphabet are used first.
        jump-label-alphabet = "abcdefghijklmnopqrstuvwxyz";

        # STATUS LINE SECTION
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
          mode.normal = "NORMAL";
          mode.insert = "INSERT";
          mode.select = "SELECT";
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
        "space".w = ":w"; # Save with <space>w
        "space".q = ":q"; # Quit with <space>q
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
          language-servers = [ "terraform-ls" ];
          auto-format = true;
          # terraform-ls provides formatting
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
        {
          name = "html";
          language-servers = [ "vscode-html-language-server" ];
          formatter = {
            command = "${pkgs.prettier}/bin/prettier";
            args = [ "--parser" "html" ];
          };
          auto-format = true;
          indent = { tab-width = 2; unit = " "; };
        }
        {
          name = "css";
          language-servers = [ "vscode-css-language-server" ];
          formatter = {
            command = "${pkgs.prettier}/bin/prettier";
            args = [ "--parser" "css" ];
          };
          auto-format = true;
          indent = { tab-width = 2; unit = " "; };
        }
        {
          name = "typescript";
          scope = "source.ts";
          language-servers = [ "typescript-language-server" ];
          formatter = {
            command = "${pkgs.prettier}/bin/prettier";
            args = [ "--parser" "typescript" ];
          };
          auto-format = true;
          indent = { tab-width = 2; unit = " "; };
        }
        {
          name = "tsx";
          scope = "source.tsx";
          language-servers = [ "typescript-language-server" ];
          formatter = {
            command = "${pkgs.prettier}/bin/prettier";
            args = [ "--parser" "typescript" ];
          };
          auto-format = true;
          indent = { tab-width = 2; unit = " "; };
        }
        {
          name = "javascript";
          scope = "source.js";
          language-servers = [ "typescript-language-server" ];
          formatter = {
            command = "${pkgs.prettier}/bin/prettier";
            args = [ "--parser" "typescript" ];
          };
          auto-format = true;
          indent = { tab-width = 2; unit = " "; };
        }
       {
          name = "jsx";
          scope = "source.jsx";
          language-servers = [ "typescript-language-server" ];
          formatter = {
            command = "${pkgs.prettier}/bin/prettier";
            args = [ "--parser" "typescript" ];
          };
          auto-format = true;
          indent = { tab-width = 2; unit = " "; };
        }
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
      nodePackages.vscode-langservers-extracted
      nodePackages.typescript-language-server
      
      # Formatters
      nixpkgs-fmt
      rustfmt
      black
      golines
      shfmt
      prettier
    ];
  };
}
