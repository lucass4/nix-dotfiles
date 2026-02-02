{ pkgs, ... }: {
  home.packages = with pkgs; [
    hadolint # Dockerfile linter
    lazydocker # Docker TUI
  ];
}
