{ config, pkgs, lib, ... }:
{
  # Add micro
  environment.systemPackages = with pkgs; [
    micro
  ];

  # Configure environment variables
  environment.variables = {
    MICRO_TRUECOLOR = 1;
  };

  # Install micro plug-ins
  environment.etc."micro/plug/detectindent" = {
    source = pkgs.fetchFromGitHub {
      owner = "dmaluka";
      repo = "micro-detectindent";
      rev = "v1.1.0";
      sha256 = "sha256-5bKEkOnhz0pyBR2UNw5vvYiTtpd96fBPTYW9jnETvq4=";
    };
  };
}
