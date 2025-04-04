{
  writeBabashkaApplication,
  cachix,
  gitMinimal,
  nix,
}:

writeBabashkaApplication {
  runtimeInputs = [
    cachix
    gitMinimal
    nix
  ];
  name = "ploy";
  text = builtins.readFile ./ploy;
}
