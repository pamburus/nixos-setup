{ config, lib, pkgs, ... }: {
  # Configure VS Code
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      golang.go
      jnoortheen.nix-ide
      rust-lang.rust-analyzer
      tamasfe.even-better-toml
      vadimcn.vscode-lldb
      yzhang.markdown-all-in-one
      zhuangtongfa.material-theme
    ];
  };

  # Initialize VS Code settings
  home.file.".config/VSCodium/User/settings.json".text = builtins.toJSON {
    "editor.fontSize" = 12;
    "workbench.colorTheme" = "One Dark Pro";
    "terminal.integrated.fontFamily" = "FiraCode Nerd Font";
    "terminal.integrated.fontWeight" = "normal";
    "terminal.integrated.fontSize" = 12;
    "terminal.integrated.enablePersistentSessions" = false;
    "terminal.integrated.persistentSessionReviveProcess" = "never";
    "terminal.integrated.hideOnStartup" = "always";
  };
}
