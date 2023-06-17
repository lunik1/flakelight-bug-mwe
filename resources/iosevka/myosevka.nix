{
  family = "Myosevka";
  spacing = "fixed";
  serifs = "sans";
  no-cv-ss = true;
  no-ligation = true;
  variants = {
    design = rec {
      ampersand = "upper-open";
      brace = "curly-flat-boundary";
      capital-g = "toothless-corner-serifless-hooked";
      capital-k = "symmetric-touching-serifless";
      capital-m = "slanted-sides-hanging-serifless";
      caret = "high";
      eight = "crossing-asymmetric";
      eszet = "longs-s-lig";
      f = "flat-hook-serifless";
      five = "oblique-upper-left-bar";
      four = "closed";
      g = "double-storey-open";
      j = "flat-hook-serifed";
      k = "symmetric-touching-serifless";
      l = "tailed-serifed";
      long-s = f;
      lower-lambda = "straight-turn";
      nine = "closed-contour";
      number-sign = "upright-open";
      one = "base";
      pilcrow = "low";
      paren = "large-contour";
      seven = "curly-serifless";
      six = "closed-contour";
      t = "flat-hook";
      underscore = "low";
      y = "straight-turn-serifless";
      zero = "reverse-slashed";
    };
    italic = {
      capital-j = "descending-serifed";
      eszet = "longs-s-lig-tailed";
      f = "flat-hook-tailed";
      g = "single-storey-serifless";
      j = "serifed";
      k = "cursive-serifless";
      long-s = "flat-hook-descending";
      t = "standard";
      y = "cursive-flat-hook-serifless";
    };
  };
  widths.normal = {
    shape = 600;
    menu = 5;
    css = "normal";
  };
}
