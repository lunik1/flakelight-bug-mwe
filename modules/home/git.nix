{ config, lib, pkgs, ... }:

let cfg = config.lunik1.home.git;
in {
  options.lunik1.home.git.enable = lib.mkEnableOption "git";

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [ git-crypt pre-commit ];

      sessionVariables = { PRE_COMMIT_ALLOW_NO_CONFIG = "1"; };
    };

    programs = {
      git = {
        enable = true;
        package = pkgs.gitSVN;
        delta = {
          enable = true;
          options = {
            syntax-theme = "gruvbox-dark";
            features = "line-numbers";
          };
        };
        ignores = [
          "$RECYCLE.BIN/"
          "*.cab"
          "*.elc"
          "*.lnk"
          "*.msi"
          "*.msix"
          "*.msm"
          "*.msp"
          "*.rel"
          "*.stackdump"
          "*.tmp"
          "*.xlk"
          "*.~vsd*"
          "*_archive"
          "*_flymake.*"
          "*~"
          ".#*"
          ".Trash-*"
          ".cask/"
          ".dir-locals.el"
          ".directory"
          ".fuse_hidden*"
          ".netrwhist"
          ".nfs*"
          ".org-id-locations"
          ".projectile"
          ".~lock.*#"
          "/.emacs.desktop"
          "/.emacs.desktop.lock"
          "/auto/"
          "/elpa/"
          "/eshell/history"
          "/eshell/lastdir"
          "/network-security.data"
          "/server/"
          "Backup of *.doc*"
          "Session.vim"
          "Sessionx.vim"
          "Thumbs.db"
          "Thumbs.db:encryptable"
          "[._]*.s[a-v][a-z]"
          "[._]*.sw[a-p]"
          "[._]*.un~"
          "[._]s[a-rt-v][a-z]"
          "[._]ss[a-gi-z]"
          "[._]sw[a-p]"
          "[Dd]esktop.ini"
          "auto-save-list"
          "dist/"
          "ehthumbs.db"
          "ehthumbs_vista.db"
          "flycheck_*.el"
          "secring.*"
          "tags"
          "tramp"
          "~$*.doc*"
          "~$*.ppt*"
          "~$*.xls*"
        ];
        lfs.enable = true;
        userEmail = "ch.gpg@themaw.xyz";
        userName = "lunik1";
        extraConfig = {
          init.defaultBranch = "master";
          pull.rebase = "true";
          push.default = "current";
          diff.algorithm = "histogram";
          github.user = "lunik1";
          gitlab.user = "lunik1";
          "delta \"magit-delta\"".line-numbers = false;
        };
      };
      gh = {
        enable = true;
        settings.git_protocol = "ssh";
      };
    };
  };
}
