{ inputs, pkgs, ... }:

{
	environment.systemPackages = [
		inputs.iloader.packages.${pkgs.stdenv.hostPlatform.system}.iloader
		pkgs.libimobiledevice
	];

	services.usbmuxd.enable = true;
}
