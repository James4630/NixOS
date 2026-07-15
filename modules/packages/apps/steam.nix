{ lib, pkgs, ... }:

{
	nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
		"steam"
		"steam-original"
		"steam-unwrapped"
		"steam-run"
	];
	
	programs.steam = {
		enable = true;
		localNetworkGameTransfers.openFirewall = true;
		extraCompatPackages = with pkgs; [
			proton-ge-bin
		];
	};

	programs.gamemode = {
		enable = true;
	};
}
