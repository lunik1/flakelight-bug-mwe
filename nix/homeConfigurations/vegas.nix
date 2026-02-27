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

        lunik1.home = {
          cli.enable = true;
        };
      }
    )
  ];
}
