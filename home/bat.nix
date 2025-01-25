{ config, lib, pkgs, ... }:
{
  # Configure bat
  home.file.".config/bat" = {
    source = "/etc/nixos/dotfiles/user/.config/bat";
  };

  # Ensure the .config files are linked before building the cache
  home.activation.bat-cache = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    ${pkgs.bat}/bin/bat cache --build
  '';
}
