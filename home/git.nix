{ config, lib, pkgs, ... }:
{
  # Configure git
  programs.git = {
    enable = true;
    extraConfig = {
      push = { autoSetupRemote = true; };
      init = { defaultBranch = "main"; };
      safe = { directory = "/etc/nixos"; };
    };
  };
}