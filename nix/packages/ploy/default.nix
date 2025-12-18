{
  writeBabashkaApplication,
  cachix,
  gitMinimal,
  lix,
  nix-output-monitor,
  nixos-rebuild,
}:

writeBabashkaApplication {
  runtimeInputs = [
    cachix
    gitMinimal
    lix
    nix-output-monitor
    nixos-rebuild
  ];
  name = "ploy";
  text = builtins.readFile ./ploy;
}
