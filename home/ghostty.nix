{ config, lib, pkgs, ... }:
{
  # Configure ghostty
  home.file.".config/ghostty/config" = {
    source = lib.mkDefault "/etc/nixos/dotfiles/user/.config/ghostty/config";
  };
}