{ config, pkgs, hl, ... }:

{
  # Add hl
  environment.systemPackages =
    [ hl.packages.${pkgs.stdenv.hostPlatform.system}.bin ];

  # Configure hl
  environment.etc."hl/config.json".text =
    builtins.toJSON { theme = "hl-dark"; };
}
