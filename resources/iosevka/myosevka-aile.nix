{ lib, ... }:

let myosevka = import ./myosevka.nix;
in lib.recursiveUpdate myosevka {
  family = "Myosevka Aile";
  desc = "Sans-serif";
  spacing = "quasi-proportional";
  variants.design = {
    a = "double-storey-serifless";
    at = "fourfold";
    capital-i = "serifless";
    capital-j = "serifless";
    capital-k = "straight-serifless";
    # capital-m = "flat-bottom";
    capital-m = "slanted-sides-flat-bottom";
    capital-w = "straight-flat-top";
    cyrl-capital-ka = "symmetric-connected-serifless";
    cyrl-capital-u = "straight";
    cyrl-ef = "serifless";
    cyrl-ka = "symmetric-connected-serifless";
    d = "toothed-serifless";
    e = "flat-crossbar";
    eszet = "longs-s-lig";
    f = "flat-hook";
    g = "single-storey-serifless";
    i = "serifless";
    j = "flat-hook-serifless";
    k = "straight-serifless";
    l = "serifless";
    long-s = "flat-hook";
    lower-iota = "flat-tailed";
    lower-lambda = "straight-turn";
    percent = "rings-continuous-slash";
    r = "compact";
    t = "flat-hook";
    u = "toothed";
    w = "straight-flat-top";
    y = "straight";
  };
  italic = {
    capital-j = "descending-serifless";
    y = "cursive";
  };
  derivingVariants.mathtt = myosevka.variants;
}
