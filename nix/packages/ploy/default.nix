{
  writeBabashkaApplication,
  cachix,
  gitMinimal,
  nix,
  podman,
  systemd,
  which,
}:

writeBabashkaApplication {
  runtimeInputs = [
    cachix
    gitMinimal
    nix
    podman
    systemd
    which
  ];
  name = "ploy";
  text = builtins.readFile ./ploy;
}
