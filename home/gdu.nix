{ config, lib, pkgs, ... }:
{
  # Configure gdu
  home.file.".gdu.yaml" = {
    source = lib.mkDefault "/etc/nixos/dotfiles/user/.gdu.yaml";
  };
}