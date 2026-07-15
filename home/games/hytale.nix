{ inputs, pkgs, ... }:

{
	home.packages = [
	    inputs.hytale-launcher.packages.${pkgs.system}.default
	  ];
}
