{ config, lib, pkgs, ... }: {
  # Configure Alacritty
  programs.alacritty = {
    enable = true;
    settings = {
      env = {
        COLORTERM = "truecolor";
        TERM = "xterm-256color";
      };
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
      font = {
        normal = {
          family = "FiraCode Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "FiraCode Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "FiraCode Nerd Font";
          style = "Italic";
        };
        size = 10;
      };
      window = {
        padding = {
          x = 6;
          y = 4;
        };
      };
    };
  };
}
