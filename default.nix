{ mkDerivation, aeson, base, hspec, network-arbitrary, network-uri
, QuickCheck, stdenv, test-invariant, text
}:
mkDerivation {
  pname = "network-uri-json";
  version = "0.1.1.0";
  src = ./.;
  libraryHaskellDepends = [ aeson base network-uri text ];
  testHaskellDepends = [
    aeson base hspec network-arbitrary network-uri QuickCheck
    test-invariant text
  ];
  homepage = "https://github.com/alunduil/network-uri-json";
  description = "FromJSON and ToJSON Instances for Network.URI";
  license = stdenv.lib.licenses.mit;
}
