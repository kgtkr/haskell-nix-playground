{
  pkgs = hackage:
    {
      packages = {
        "ghc-prim".revision = (((hackage."ghc-prim")."0.6.1").revisions).default;
        "base".revision = (((hackage."base")."4.14.3.0").revisions).default;
        "rts".revision = (((hackage."rts")."1.0.1").revisions).default;
        "integer-gmp".revision = (((hackage."integer-gmp")."1.0.3.0").revisions).default;
        };
      compiler = {
        version = "8.10.7";
        nix-name = "ghc8107";
        packages = {
          "ghc-prim" = "0.6.1";
          "base" = "4.14.3.0";
          "rts" = "1.0.1";
          "integer-gmp" = "1.0.3.0";
          };
        };
      };
  extras = hackage:
    {
      packages = {
        haskell-nix-playground = ./.plan.nix/haskell-nix-playground.nix;
        };
      };
  modules = [
    ({ lib, ... }:
      { packages = { "haskell-nix-playground" = { flags = {}; }; }; })
    ({ lib, ... }:
      {
        packages = {
          "haskell-nix-playground".components.exes."haskell-nix-playground-app".planned = lib.mkOverride 900 true;
          "ghc-prim".components.library.planned = lib.mkOverride 900 true;
          "rts".components.library.planned = lib.mkOverride 900 true;
          "haskell-nix-playground".components.tests."haskell-nix-playground-test".planned = lib.mkOverride 900 true;
          "base".components.library.planned = lib.mkOverride 900 true;
          "integer-gmp".components.library.planned = lib.mkOverride 900 true;
          "haskell-nix-playground".components.library.planned = lib.mkOverride 900 true;
          };
        })
    ];
  }