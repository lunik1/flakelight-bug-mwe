{ lib, ... }:

let myosevka = import ./myosevka.nix;
in lib.recursiveUpdate myosevka {
  family = "Myosevka Etoile";
  desc = "Slab-serif";
  spacing = "quasi-proportional";
  serifs = "slab";
  variants.design = {
    at = "fourfold";
    capital-g = "toothless-corner-serifed-hooked";
    capital-k = "straight-serifed";
    capital-m = "slanted-sides-hanging-serifed";
    capital-w = "straight-flat-top-serifed";
    f = "flat-hook-serifed";
    j = "flat-hook-serifed";
    t = "flat-hook";
    w = "straight-flat-top-serifed";
    long-s = "flat-hook-bottom-serifed";
  };
  italic = { f = "flat-hook-tailed"; };
  derivingVariants.mathtt = myosevka.variants;
}
