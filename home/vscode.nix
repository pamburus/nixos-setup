{ config, lib, pkgs, ... }:
{
  # Configure VS Code
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    extensions = with pkgs.vscode-extensions; [
      golang.go
      jnoortheen.nix-ide
      tamasfe.even-better-toml
      yzhang.markdown-all-in-one
      zhuangtongfa.material-theme
    ];
  };

  # Initialize VS Code settings
  home.file.".config/VSCodium/User/settings.json".text = builtins.toJSON {
    "editor.fontSize" = 12;
    "workbench.colorTheme" = "One Dark Pro";
    "terminal.integrated.fontFamily" = "Hack Nerd Font Mono";
    "terminal.integrated.fontWeight" =  "normal";
    "terminal.integrated.fontSize" =  12;
  };
}