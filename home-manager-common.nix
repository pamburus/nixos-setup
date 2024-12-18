{ config, lib, pkgs, ... }:
{
  dconf.settings = {
    "org/gnome/desktop/peripherals/keyboard" = {
      delay = lib.hm.gvariant.mkUint32 250;
      repeat-interval = lib.hm.gvariant.mkUint32 25;
      repeat = true;
    };
  };

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
    initExtraFirst =
      ''
        # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
        # Initialization code that may require console input (password prompts, [y/n]
        # confirmations, etc.) must go above this block; everything else may go below.
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '';
    initExtra =
      ''
        # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

        # Configure atuin
        eval "''$(atuin init zsh --disable-up-arrow)"
      '';
  };
  home.file.".p10k.zsh" = {
    source = lib.mkDefault "/etc/nixos/dotfiles/user/.p10k.zsh";
  };

  # Configure atuin
  home.file.".config/atuin/config.toml" = {
    source = lib.mkDefault "/etc/nixos/dotfiles/user/.config/atuin/config.toml";
  };
  home.file.".config/atuin/themes" = {
    source = lib.mkDefault "/etc/nixos/dotfiles/user/.config/atuin/themes";
    recursive = true;
  };

  # Configure git
  programs.git = {
    enable = true;
    extraConfig = {
      push = { autoSetupRemote = true; };
      init = { defaultBranch = "main"; };
      safe = { directory = "/etc/nixos"; };
    };
  };

  # Configure Alacritty
  programs.alacritty = {
    enable = true;
    settings = {
      mouse = { hide_when_typing = false; };
      cursor = {
        style = {
          shape = "Beam";
          blinking = "On";
        };
      };
      colors = {
        cursor = {
          text = "CellBackground";
          cursor = "#d17277";
        };
      };
      font = {
        normal = {
          family = "LiterationMono Nerd Font Mono";
          style = "Regular";
        };
        bold = {
          style = "Bold";
        };
        italic = {
          style = "Italic";
        };
        size = 10;
      };
    };
  };

  # Configure micro
  home.file.".config/micro/settings.json".text = builtins.toJSON {
    hltaberrors = true;
    hltrailingws = true;
    rmtrailingws = true;
    tabsize = 4;
    "*.nix" = {
      tabsize = 2;
    };
  };
  home.file.".config/micro/plug" = {
    source = "/etc/micro/plug";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
