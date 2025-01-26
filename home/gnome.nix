{ config, lib, pkgs, ... }:
{
  gtk = {
    enable = true;
    theme = {
      package = pkgs.whitesur-gtk-theme;
      name = "WhiteSur-Dark";
    };
    iconTheme = {
      name = "WhiteSur";
    };
    gtk3.extraConfig = {};
    gtk4.extraConfig = {};
  };

  programs.gnome-shell = {
    enable = true;
    extensions = [
      {
        package = pkgs.gnome-shell-extensions;
        id = "colortint@matt.serverus.co.uk";
      }
      {
        package = pkgs.gnome-shell-extensions;
        id = "user-theme@gnome-shell-extensions.gcampax.github.com";
      }
    ];
    theme = {
      package = pkgs.whitesur-gtk-theme;
      name = "WhiteSur-Dark-solid";
    };
  };

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.quintom-cursor-theme;
    name = "Quintom_Snow";
    size = 24;
  };

  dconf.settings = {
    "org.gnome.desktop.interface" = {
      text-scaling-factor = 1.0;
    };
    "org/gnome/desktop/peripherals/keyboard" = {
      delay = lib.hm.gvariant.mkUint32 250;
      repeat-interval = lib.hm.gvariant.mkUint32 33;
      repeat = true;
    };
    "org/gnome/desktop/background" = {
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/swoosh-l.jxl";
      picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/swoosh-d.jxl";
      primary-color = "#730166";
    };
  };
}
