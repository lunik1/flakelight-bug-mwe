{
  writeBabashkaApplication,
  podman,
  systemd,
}:

writeBabashkaApplication {
  runtimeInputs = [
    podman
    systemd
  ];
  name = "update-containers";
  text = builtins.readFile ./update-containers;
}
