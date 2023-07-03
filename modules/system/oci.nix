# For Oracle cloud instances

{ config, pkgs, lib, modulesPath, ... }:

with lib;

let cfg = config.lunik1.system.oci;
in
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  options.lunik1.system.oci = {
    enable = lib.mkEnableOption "Oracle cloud compatibility";
    efi = lib.mkOption {
      default = pkgs.stdenv.hostPlatform.isAarch64;
      internal = true;
      description = "Whether the OCI instance is using EFI.";
    };
  };

  config = lib.mkIf cfg.enable {
    boot = {
      kernelParams = [
        "nvme.shutdown_timeout=10"
        "nvme_core.shutdown_timeout=10"
        "libiscsi.debug_libiscsi_eh=1"
        "crash_kexec_post_notifiers"

        # VNC console
        "console=tty1"

        # x86_64-linux
        "console=ttyS0"

        # aarch64-linux
        "console=ttyAMA0,115200"
      ];
      growPartition = true;

      loader = {
        efi.canTouchEfiVariables = false;
        grub = {
          device = if cfg.efi then "nodev" else "/dev/sda";
          splashImage = null;
          extraConfig = ''
            serial --unit=0 --speed=115200 --word=8 --parity=no --stop=1
            terminal_input --append serial
            terminal_output --append serial
          '';
          efiInstallAsRemovable = cfg.efi;
          efiSupport = cfg.efi;
        };
      };
    };

    networking.timeServers = [ "169.254.169.254" ];

    lunik1.system.ssh-server.enable = true;
  };
}
