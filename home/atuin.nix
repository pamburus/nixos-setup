{ config, lib, pkgs, ... }:
{
  # Configure atuin
  home.file.".config/atuin/config.toml" = {
    source = lib.mkDefault "/etc/nixos/dotfiles/user/.config/atuin/config.toml";
  };

  # Set up themes
  home.file.".config/atuin/themes" = {
    source = lib.mkDefault "/etc/nixos/dotfiles/user/.config/atuin/themes";
    recursive = true;
  };
}