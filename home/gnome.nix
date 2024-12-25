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
}