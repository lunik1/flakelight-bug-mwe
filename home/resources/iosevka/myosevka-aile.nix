{ lib, ... }:

let myosevka = import ./myosevka.nix;
in lib.recursiveUpdate myosevka {
  family = "Myosevka Aile";
  desc = "Sans-serif";
  spacing = "quasi-proportional";
  variants.design = {
    at = "fourfold";
    j = "flat-hook-serifless";
    capital-i = "serifless";
    capital-j = "serifless";
    capital-w = "straight-flat-top";
    g = "single-storey";
    r = "compact";
    a = "double-storey";
    d = "toothed";
    u = "toothed";
    i = "serifless";
    l = "serifless";
    f = "flat-hook";
    t = "flat-hook";
    w = "straight-flat-top";
  };
  derivingVariants.mathtt = myosevka.variants;
}
