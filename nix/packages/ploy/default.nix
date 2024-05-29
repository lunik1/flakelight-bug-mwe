{
  writeBabashkaApplication,
  cachix,
  gitMinimal,
  nix,
  which,
}:

writeBabashkaApplication {
  runtimeInputs = [
    cachix
    gitMinimal
    nix
    which
  ];
  name = "ploy";
  text = builtins.readFile ./ploy;
}
