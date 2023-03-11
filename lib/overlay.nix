self: super:

{
  lib = super.lib.recursiveUpdate (super.lib or { }) {
    lunik1 = {
      /* Returns true if file f is gpg encrypted
      */
      isEncrypted = with self.pkgs;
        f:
          !lib.hasInfix "text" (lib.fileContents
            (runCommandNoCCLocal "is-encrypted"
              {
                buildInputs = [ file ];
                src = f;
              } "file $src > $out"));
    };
  };
}
