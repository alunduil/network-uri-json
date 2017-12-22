let
  config = {
    packageOverrides = pkgs: rec {
        haskellPackages = pkgs.haskellPackages.override {
          overrides = haskellPackagesNew: haskellPackagesOld: rec {

            network-uri-json =
              haskellPackagesNew.callPackage ./default.nix { };

          };
        };
    };
  };

  pkgs = import <nixpkgs> { inherit config; };
in
  { network-uri-json = pkgs.haskellPackages.network-uri-json;
  }
