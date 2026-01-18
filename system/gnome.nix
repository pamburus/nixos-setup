{ config, pkgs, lib, ... }: {
  # Add gnome packages
  environment.systemPackages = with pkgs; [
    gnome-tweaks
    gnome-shell-extensions
    whitesur-gtk-theme
    whitesur-icon-theme
    nightfox-gtk-theme
    tokyonight-gtk-theme
    theme-obsidian2
    breeze-hacked-cursor-theme
    quintom-cursor-theme
  ];

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Enable the gnome-keyring secrets vault.
  # Will be exposed through DBus to programs willing to store secrets.
  services.gnome.gnome-keyring.enable = true;
}
