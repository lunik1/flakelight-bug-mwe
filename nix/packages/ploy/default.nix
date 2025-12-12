{
  writeBabashkaApplication,
  cachix,
  gitMinimal,
  lix,
  nixos-rebuild-ng,
}:

writeBabashkaApplication {
  runtimeInputs = [
    cachix
    gitMinimal
    lix
    nixos-rebuild-ng
  ];
  name = "ploy";
  text = builtins.readFile ./ploy;
}
