{ inputs, pkgs, ... }:

{
	services.clipse = {
		enable = true;
		systemdTarget = "graphical-session.target";
		settings = {
			#
		};
	};
}
