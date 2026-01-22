{ pkgs, ... }: {
  home.packages = with pkgs; [ pre-commit cookiecutter poetry yapf ];
}
