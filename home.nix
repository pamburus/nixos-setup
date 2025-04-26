{ config, lib, pkgs, ... }:
{
  imports = [
    ./home/gnome.nix
    ./home/zsh.nix
    ./home/alacritty.nix
    ./home/atuin.nix
    ./home/gdu.nix
    ./home/ghostty.nix
    ./home/git.nix
    ./home/micro.nix
    ./home/bat.nix
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
