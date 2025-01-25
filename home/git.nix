{ config, lib, pkgs, ... }:
{
  # Configure git
  programs.git = {
    enable = true;
    extraConfig = {
      push = { autoSetupRemote = true; };
      init = { defaultBranch = "main"; };
      safe = { directory = "/etc/nixos"; };

      core = {
        pager = "delta --paging always --max-line-length 65536";
      };

      interactive = {
        diffFilter = "delta --color-only";
      };

      delta = {
        features = "decorations";
        whitespace-error-style = "22 reverse";
        side-by-side = true;
        hunk-header-decoration-style = "brightblack ul";
        paging = "always";
        line-numbers = true;
        decorations = {
          commit-decoration-style = "bold yellow box ul";
          file-style = "bold yellow ul";
          file-decoration-style = "none";
        };
      };
    };
  };
}
