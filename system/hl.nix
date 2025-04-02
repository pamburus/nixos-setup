{ config, pkgs, lib, ... }:

let
  flake = builtins.getFlake "github:pamburus/hl";
  hl = flake.packages.${pkgs.system}.default;
in
{
  # Add hl
  environment.systemPackages = with pkgs; [
    hl
  ];

  # Configure hl
  environment.etc."hl/config.json".text = builtins.toJSON {
    theme = "hl-dark";
  };
}
