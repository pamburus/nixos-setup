{ config, lib, pkgs, ... }:
{
  # Configure zsh
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];
    initContent = lib.mkMerge [ 
      (lib.mkOrder 100 ''
        # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
        # Initialization code that may require console input (password prompts, [y/n]
        # confirmations, etc.) must go above this block; everything else may go below.
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '')
      (lib.mkOrder 1000 ''
        # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

        # Configure atuin
        ! command -V atuin >/dev/null || eval "''$(atuin init zsh --disable-up-arrow)"
      '')
      ];
  };

  # Configure p10k
  home.file.".p10k.zsh" = {
    source = lib.mkDefault "/etc/nixos/dotfiles/user/.p10k.zsh";
  };
}