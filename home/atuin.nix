{ config, lib, pkgs, self, ... }: {
  # Configure atuin
  home.file.".config/atuin/config.toml" = {
    source = lib.mkDefault "${self}/dotfiles/user/.config/atuin/config.toml";
  };

  # Set up themes
  home.file.".config/atuin/themes" = {
    source = lib.mkDefault "${self}/dotfiles/user/.config/atuin/themes";
    recursive = true;
  };
}
