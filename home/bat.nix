{ config, lib, pkgs, self, ... }:

{
  # Configure bat
  home.file.".config/bat" = {
    source = "${self}/dotfiles/user/.config/bat";
    recursive = true;
  };

  # Ensure the .config files are linked before building the cache
  home.activation.bat-cache = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    ${pkgs.bat}/bin/bat cache --build
  '';
}
