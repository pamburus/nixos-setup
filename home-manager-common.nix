{ config, lib, pkgs, ... }:
{
  dconf.settings = {
    "org/gnome/desktop/peripherals/keyboard" = {
      delay = lib.hm.gvariant.mkUint32 250;
      repeat-interval = lib.hm.gvariant.mkUint32 25;
      repeat = true;
    };
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "colortint@matt.serverus.co.uk"
        "user-theme@gnome-shell-extensions.gcampax.github.com"
      ];
    };
    "org/gnome/shell/extensions/user-theme" = {
      name = "Obsidian-2-Aqua";
    };
    "org/gnome/desktop/interface" = {
      icon-theme = "Obsidian-Mint";
    };
    "org/gnome/desktop/background" = {
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/swoosh-l.jxl";
      picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/swoosh-d.jxl";
      primary-color = "#730166";
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
        draw_bold_text_with_bright_colors = true;
        primary = {
          background = "#1d2025";
          bright_foreground = "#cccccc";
          dim_foreground = "#676f82";
          foreground = "#a0b0bd";
        };
        normal = {
          black = "#1d2025";
          blue = "#4892e2";
          cyan = "#29a9bc";
          green = "#a1c281";
          magenta = "#bb7cd7";
          red = "#d17277";
          white = "#acb2be";
          yellow = "#d9ac6e";
        };
        bright = {
          black = "#676f82";
          blue = "#66acff";
          cyan = "#69c6d1";
          green = "#a9d47f";
          magenta = "#c671eb";
          red = "#e6676d";
          white = "#cccccc";
          yellow = "#eebb64";
        };
      };
      env = {
        COLORTERM = "truecolor";
        TERM = "xterm-256color";
      };
      font = {
        normal = {
          family = "Hack Nerd Font Mono";
          style = "Regular";
        };
        bold = {
          family = "Hack Nerd Font Mono";
          style = "Bold";
        };
        italic = {
          family = "Hack Nerd Font Mono";
          style = "Italic";
        };
        size = 10;
      };
    };
  };

  # Configure micro
  home.file.".config/micro/settings.json".text = builtins.toJSON {
    colorscheme = "one-dark";
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

  # Configure VS Code
  home.file.".config/VSCodium/User/settings.json".text = builtins.toJSON {
    "editor.fontSize" = 12;
    "workbench.colorTheme" = "One Dark Pro";
    "terminal.integrated.fontFamily" = "Hack Nerd Font Mono";
    "terminal.integrated.fontWeight" =  "normal";
    "terminal.integrated.fontSize" =  12;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
