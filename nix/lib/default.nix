{ lib, ... }:

let
  containerDefaults = timeZone: {
    environment = {
      TZ = timeZone;
    };
    volumes = [
      "/etc/localtime:/etc/localtime:ro"
    ];
    extraOptions = [
      "--mount=type=tmpfs,destination=/tmp,tmpfs-mode=777"
      "--mount=type=tmpfs,destination=/run,tmpfs-mode=777"
    ];
  };
in
rec {
  mkPodmanResource = resource: podman: name: {
    path = [ podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman ${resource} inspect ${name} || podman ${resource} create ${name}
    '';
  };

  mkPodmanVolume = mkPodmanResource "volume";

  mkPodmanNetwork = mkPodmanResource "network";

  mkPodmanContainer = timeZone: cfg: lib.mkMerge [ (containerDefaults timeZone) cfg ];
}
