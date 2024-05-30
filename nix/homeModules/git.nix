{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lunik1.home.git;
in
{
  options.lunik1.home.git.enable = lib.mkEnableOption "git";

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        git-crypt
        glab
        pre-commit
      ];

      sessionVariables = {
        PRE_COMMIT_ALLOW_NO_CONFIG = "1";
      };
    };

    sops.secrets = {
      gh_token = { };
      gitlab_token = { };
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
          ".dir-locals-2.el"
          ".directory"
          ".fuse_hidden*"
          ".netrwhist"
          ".nfs*"
          ".org-id-locations"
          ".projectile"
          ".stfolder"
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
          ".direnv/"
          "*.DS_Store"
        ];
        lfs.enable = true;
        userEmail = "ch.gpg@themaw.xyz";
        userName = "lunik1";
        extraConfig = {
          init.defaultBranch = "master";
          commit.verbose = true;
          pull.rebase = "true";
          push = {
            default = "current";
            followtags = true;
          };
          diff = {
            algorithm = "histogram";
            colorMoved = "default";
          };
          merge = {
            conflictstyle = "zdiff3";
            keepbackup = false;
          };
          rebase.autosquash = true;
          rerere.enabled = true;
          github.user = "lunik1";
          gitlab.user = "lunik1";
          "delta \"magit-delta\"".line-numbers = false;
          url = {
            "git@github.com:".pushInsteadOf = "https://github.com/";
            "git@gitlab.com:".pushInsteadOf = "https://gitlab.com/";
            "git@codeberg.org:".pushInsteadOf = "https://codeberg.org";
          };
          transfer.fsckobjects = true;
          fetch.fsckobjects = true;
          receive.fsckObjects = true;
        };
      };
      gh = {
        enable = true;
        settings.git_protocol = "ssh";
      };
      zsh = {
        envExtra = ''
          [ -f "''${XDG_RUNTIME_DIR}/secrets/gh_token" ] \
            && export GH_TOKEN=$(<"''${XDG_RUNTIME_DIR}/secrets/gh_token")

          [ -f "''${XDG_RUNTIME_DIR}/secrets/gitlab_token" ] \
            && export GITLAB_TOKEN=$(<"''${XDG_RUNTIME_DIR}/secrets/gitlab_token")
        '';
      };
    };
  };
}
