{ config, pkgs, lib, ... }:

let
  flake = builtins.getFlake "github:pamburus/termframe";
  termframe = flake.packages.${pkgs.system}.default;
in
{
  # Add termframe
  environment.systemPackages = with pkgs; [
    termframe
  ];
}
