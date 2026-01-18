{ config, lib, pkgs, self, ... }:

{
  # Configure ghostty
  home.file.".config/ghostty/config" = {
    source = lib.mkDefault "${self}/dotfiles/user/.config/ghostty/config";
  };
}
