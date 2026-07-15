{ pkgs, ... }:

{
	environment.systemPackages = [
	  pkgs.kdePackages.gwenview
	];
}
