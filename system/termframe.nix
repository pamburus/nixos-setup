{ config, pkgs, termframe, ... }:

{
  # Add termframe
  environment.systemPackages =
    [ termframe.packages.${pkgs.stdenv.hostPlatform.system}.bin ];
}
