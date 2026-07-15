{ pkgs ? import <nixpkgs> {} }:

let

  python = pkgs.python313;
  
  pythonEnv = python.withPackages (ps: with ps; [
    music-tag
    pyarr
  ]);
  
  slskd_api = pkgs.python313Packages.buildPythonPackage rec {
      pname = "slskd_api";
      version = "0.2.3";
  
      src = pkgs.fetchPypi {
        inherit pname version;
        hash = "sha256-cArINp1EuKJRxyL9wQo9B2Qs6h9L2t06sCzNxxpnYiU=";
      };
  
      pyproject = true;
  
      build-system = with pkgs.python313Packages; [
        setuptools
        setuptools-git-versioning
      ];

      propagatedBuildInputs = with pkgs.python313Packages; [
      	requests
      ];
    };

in

pkgs.mkShell {
  buildInputs = [ pythonEnv slskd_api ];
  shellHook = ''
    echo "Activated dev shell with: $(python -V)"
  '';
}
