{ pkgs, ... }: {
  home.packages = with pkgs; [ tgswitch tfswitch tflint terraform-docs ];
}
