# For Hetzner guests

{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

let
  cfg = config.lunik1.home.hetzner;
in
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  options.lunik1.home.hetzner.enable = lib.mkEnableOption "Hetzner cloud compatibility";

  config = lib.mkIf cfg.enable {
    boot.initrd.availableKernelModules = [
      "xchi_pci"
      "virtio_pci"
      "virtio_scsi"
      "usbhid"
      "sr_mod"
    ];
    networking.timeServers = [
      "ntp1.hetzner.de"
      "ntp2.hetzner.com"
      "ntp3.hetzner.net"
    ];
  };
}
