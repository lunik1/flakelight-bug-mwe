{
  hmModules,
  ...
}:

{
  system = "x86_64-linux";
  modules = [
    (
      {
        lib,
        ...
      }:
      {
        system.stateVersion = "21.05";
        networking.hostName = "machine";

        fileSystems = {
          "/" = {
            device = "/dev/disk/by-uuid/fake-uuid";
            fsType = "xfs";
          };
        };

        boot.loader.systemd-boot.enable = true;

        users.users.corin.isNormalUser = true;

        home-manager.users.corin = {
          imports = hmModules;

          home = {
            username = "corin";
            homeDirectory = lib.mkForce "/home/corin";
            stateVersion = "21.05";
          };

          lunik1.home = {
            cli.enable = true;
          };
        };
      }
    )
  ];
}
