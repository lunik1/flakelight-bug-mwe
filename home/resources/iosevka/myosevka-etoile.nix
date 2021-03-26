{ lib, ... }:

let myosevka = import ./myosevka.nix;
in lib.recursiveUpdate myosevka {
  family = "Myosevka Etoile";
  desc = "Slab-serif";
  spacing = "quasi-proportional";
  serifs = "slab";
  variants.design = {
    at = "fourfold";
    capital-w = "straight-flat-top";
    j = "serifed";
    w = "straight-flat-top";
  };
  derivingVariants.mathtt = myosevka.variants;
}
