{
  system = "x86_64-linux";
  modules = [
    (
      { pkgs, ... }:
      {
        home = {
          username = "corin";
          homeDirectory = "/home/corin";
          packages = with pkgs; [ lunik1-nur.bach ];
          stateVersion = "21.11";
        };

        targets.genericLinux.enable = true;

        programs.zsh = {
          ## Machine-specifc dir hashes
          dirHashes = {
            win = "/mnt/c/Users/chmic";
          };
          profileExtra = ''
            setxkbmap -option compose:ralt
          '';
        };

        nix.settings = {
          max-jobs = 2;
          cores = 16;
        };

        lunik1.home = {
          core.enable = true;
          cli.enable = true;

          emacs = {
            enable = true;
            gui = true;
          };
          fonts.enable = true;
          git.enable = true;
          gpg.enable = true;
          neovim.enable = true;
          wsl.enable = true;

          lang = {
            c.enable = true;
            data.enable = true;
            julia.enable = true;
            nix.enable = true;
            prose.enable = true;
            python.enable = true;
            sh.enable = true;
          };
        };
      }
    )
  ];
}
