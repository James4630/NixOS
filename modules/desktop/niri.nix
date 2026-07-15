{ inputs, pkgs, ... }:

{
	imports = [
		inputs.niri.nixosModules.niri
	];

	nixpkgs.overlays = [ inputs.niri.overlays.niri ];

	programs.niri = {
		enable = true;
		package = pkgs.niri-unstable;
	};

	xdg.portal.config = {
	  niri = {
	    "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
	  };
	};

	programs.gdk-pixbuf.modulePackages = [
		pkgs.librsvg
	];

	security.pam.services.hyprlock = {};
}
