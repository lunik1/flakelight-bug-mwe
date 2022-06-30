# This file is a modified version of
#
#   https://github.com/vpsfreecz/vpsadminos/blob/master/os/lib/nixos-container/vpsadminos.nix
#
# It may need to be synced with the upstream version if issues arise

{ config, pkgs, lib, ... }:

with lib;

let cfg = config.lunik1.system.vpsadminos;
in {
  options.lunik1.system.vpsadminos.enable =
    lib.mkEnableOption "vpsAdminOS compatibility";

  config = lib.mkIf cfg.enable {
    networking.dhcpcd.extraConfig = "noipv4ll";

    systemd = {
      services = {
        systemd-udev-trigger.enable = false;
        rpc-gssd.enable = false;
        systemd-sysctl.enable = false;
      };
      sockets."systemd-journald-audit".enable = false;
      mounts = [{
        where = "/sys/kernel/debug";
        enable = false;
      }];
    };

    boot = {
      isContainer = true;
      enableContainers = mkDefault true;
      loader.initScript.enable = true;
      specialFileSystems."/run/keys".fsType = lib.mkForce "tmpfs";
      systemdExecutable = mkDefault
        "/run/current-system/systemd/lib/systemd/systemd systemd.unified_cgroup_hierarchy=0";
    };

    # Overrides for <nixpkgs/nixos/modules/virtualisation/container-config.nix>
    documentation = {
      enable = mkOverride 500 true;
      nixos.enable = mkOverride 500 true;
    };
    networking.useHostResolvConf = mkOverride 500 false;
    services.openssh.startWhenNeeded = mkOverride 500 false;

    # Bring up the network, /ifcfg.{add,del} are supplied by the vpsAdminOS host
    systemd.services.networking-setup = {
      description =
        "Load network configuration provided by the vpsAdminOS host";
      before = [ "network.target" ];
      wantedBy = [ "network.target" ];
      after = [ "network-pre.target" ];
      path = [ pkgs.iproute ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.bash}/bin/bash /ifcfg.add";
        ExecStop = "${pkgs.bash}/bin/bash /ifcfg.del";
      };
      unitConfig.ConditionPathExists = "/ifcfg.add";
    };
  };
}
