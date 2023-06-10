{ lib, ... }:

let myosevka = import ./myosevka.nix;
in lib.recursiveUpdate myosevka {
  family = "Myosevka Aile";
  desc = "Sans-serif";
  spacing = "quasi-proportional";
  variants.design = rec {
    a = "double-storey-serifless";
    at = "fourfold";
    capital-i = "serifless";
    capital-j = "serifless";
    capital-k = "straight-serifless";
    capital-m = "slanted-sides-flat-bottom-serifless";
    capital-w = "straight-flat-top-serifless";
    cyrl-capital-ka = "symmetric-connected-serifless";
    cyrl-capital-u = "straight-serifless";
    cyrl-ef = "serifless";
    cyrl-ka = "symmetric-connected-serifless";
    d = "toothed-serifless";
    e = "flat-crossbar";
    eszet = "longs-s-lig";
    f = "flat-hook-serifless";
    g = "single-storey-serifless";
    i = "serifless";
    j = "flat-hook-serifless";
    k = "straight-serifless";
    l = "serifless";
    long-s = f;
    lower-iota = "flat-tailed";
    lower-lambda = "straight-turn";
    percent = "rings-continuous-slash";
    r = "compact-serifless";
    t = "flat-hook";
    u = "toothed-serifless";
    w = "straight-flat-top-serifless";
    y = "straight-serifless";
  };
  italic = {
    capital-j = "descending-serifless";
    y = "cursive";
  };
  derivingVariants.mathtt = myosevka.variants;
}
