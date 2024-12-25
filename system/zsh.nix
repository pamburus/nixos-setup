{ config, pkgs, lib, ... }:
{
  # Add zsh packages
  environment.systemPackages = with pkgs; [
    zsh
    zsh-powerlevel10k
  ];

  # Configure default settings for all users
  users.defaultUserShell = pkgs.zsh;

  # Configure zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "lsd -lah";
      update = "sudo nixos-rebuild switch";
      pbcopy = "xclip -selection clipboard";
      pbpaste = "xclip -selection clipboard -o";
    };
  };
}
