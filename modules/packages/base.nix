{ pkgs, ... }:

{
	environment.systemPackages = with pkgs; [
		wget
		htop
		btop
		powertop
		pciutils
		rsync
		zip
		unzip
	];
}
