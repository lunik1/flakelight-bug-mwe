{
  system = "x86_64-linux";
  modules = [
    (
      { pkgs, ... }:
      {
        home = {
          username = "corin";
          homeDirectory = "/home/corin";
          stateVersion = "21.11";
        };

        lunik1.home = {
          cli.enable = true;
        };
      }
    )
  ];
}
