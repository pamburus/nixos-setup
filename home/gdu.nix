{ config, lib, pkgs, self, ... }:

{
  # Configure gdu
  home.file.".gdu.yaml" = {
    source = lib.mkDefault "${self}/dotfiles/user/.gdu.yaml";
  };
}
