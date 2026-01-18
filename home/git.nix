{ config, lib, pkgs, self, ... }: {
  # Configure git
  programs.git = {
    enable = true;
    settings = {
      push = { autoSetupRemote = true; };
      init = { defaultBranch = "main"; };
      safe = { directory = "/etc/nixos"; };
      core = { pager = "delta"; };

      interactive = { diffFilter = "delta --color-only"; };

      delta = {
        navigate = true; # use n and N to move between diff sections
        dark = true; # or light = true, or omit for auto-detection
        side-by-side = true;
        line-numbers = true;
        paging = "always";
        features = "pamburus";
        pamburus = {
          commit-decoration-style = "bold box ul #34fd50";
          dark = true;
          file-decoration-style = "none";
          file-style = "omit";
          hunk-header-decoration-style = "#307484 box ul";
          hunk-header-file-style = "#8090a0";
          hunk-header-line-number-style = "bold #03a4ff";
          hunk-header-style = "file line-number syntax";
          line-numbers = true;
          line-numbers-left-format = "{nm:>1}┊";
          line-numbers-left-style = "#467890";
          line-numbers-minus-style = "#ff0051 bold";
          line-numbers-plus-style = "#03e57f bold";
          line-numbers-right-format = "{np:>1}┊";
          line-numbers-right-style = "#467890";
          line-numbers-zero-style = "#507080";
          minus-emph-style = "syntax bold #ab0037";
          minus-style = "syntax #6f1b37";
          plus-emph-style = "syntax bold #007032";
          plus-style = "syntax #114d35";
          whitespace-error-style = "#280050";
          side-by-side = true;
          syntax-theme = "pamburus";
        };
      };
    };

    includes =
      [{ path = "${self}/dotfiles/user/.config/delta/themes.gitconfig"; }];
  };
}
