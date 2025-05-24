{
  writeBabashkaApplication,
  cachix,
  gitMinimal,
  nix,
  nixos-rebuild-ng,
}:

writeBabashkaApplication {
  runtimeInputs = [
    cachix
    gitMinimal
    nix
    nixos-rebuild-ng
  ];
  name = "ploy";
  text = builtins.readFile ./ploy;
}
