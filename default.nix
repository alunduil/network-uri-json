{ mkDerivation, aeson, base, hspec, hspec-discover
, network-arbitrary, network-uri, stdenv, test-invariant, text
}:
mkDerivation {
  pname = "network-uri-json";
  version = "0.4.0.0";
  src = ./.;
  libraryHaskellDepends = [ aeson base network-uri text ];
  testHaskellDepends = [
    aeson base hspec network-arbitrary network-uri test-invariant text
  ];
  testToolDepends = [ hspec-discover ];
  homepage = "https://github.com/alunduil/network-uri-json";
  description = "FromJSON and ToJSON Instances for Network.URI";
  license = stdenv.lib.licenses.mit;
}
