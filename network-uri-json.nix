let
  config = {
    packageOverrides = pkgs: rec {
        haskellPackages = pkgs.haskellPackages.override {
          overrides = haskellPackagesNew: haskellPackagesOld: rec {

            network-arbitrary =
              haskellPackagesNew.callPackage ./network-arbitrary.nix { };

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
