{ pkgs ? import <nixpkgs> {} }:

let

  python = pkgs.python313;
  
  pythonEnv = python.withPackages (ps: with ps; [
    music-tag
    pyarr
  ]);
  
  slskd_api = pkgs.python313Packages.buildPythonPackage rec {
    pname = "slskd-api";
    version = "0.1.5";
    
    src = pkgs.fetchPypi {
      inherit pname version;
      sha256 = "LmWP7bnK5IVid255qS2NGOmyKzGpUl3xsO5vi5uJI88=";
    };
    
    nativeBuildInputs = with pkgs.python313Packages; [
      setuptools
      wheel
      pip
      setuptools-git-versioning
    ];
    
  };

in

pkgs.mkShell {
  buildInputs = [ pythonEnv slskd_api ];
  shellHook = ''
    echo "Activated dev shell with: $(python -V)"
  '';
}
