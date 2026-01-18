{ config, lib, pkgs, self, ... }: {
  # Configure micro
  home.file.".config/micro/settings.json".text = builtins.toJSON {
    colorscheme = "one-dark";
    hltaberrors = true;
    hltrailingws = true;
    rmtrailingws = true;
    tabsize = 4;
    "*.nix" = { tabsize = 2; };
  };

  # Set up plugins
  home.file.".config/micro/plug" = {
    source = "${self}/dotfiles/user/.config/micro/plug";
    recursive = true;
  };
}
