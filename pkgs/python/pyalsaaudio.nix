{ lib, python3Packages, alsaLib }:

python3Packages.buildPythonPackage rec {
  pname = "pyalsaaudio";
  version = "0.9.0";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "0s8yw1h601cw2sqgxm7sjh7li8l3v5l380xm8wq2mbf86v3nk81w";
  };

  buildInputs = [ alsaLib ];

  doCheck = false;
}
