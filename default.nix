{ mkDerivation, aeson, base, hspec, network-arbitrary, network-uri
, stdenv, test-invariant, text
}:
mkDerivation {
  pname = "network-uri-json";
  version = "0.1.2.1";
  src = ./.;
  libraryHaskellDepends = [ aeson network-uri text ];
  testHaskellDepends = [
    aeson base hspec network-arbitrary network-uri test-invariant text
  ];
  homepage = "https://github.com/alunduil/network-uri-json";
  description = "FromJSON and ToJSON Instances for Network.URI";
  license = stdenv.lib.licenses.mit;
}
