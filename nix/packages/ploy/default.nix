{
  writeBabashkaApplication,
  cachix,
  gitMinimal,
  lix,
  nix-output-monitor,
  nixos-rebuild-ng,
}:

writeBabashkaApplication {
  runtimeInputs = [
    cachix
    gitMinimal
    lix
    nix-output-monitor
    nixos-rebuild-ng
  ];
  name = "ploy";
  text = builtins.readFile ./ploy;
}
