{ pkgs, ... }:

{
	programs.waybar = {
		enable = true;
		systemd.enable = true;
		settings = [ ];
	};

	xdg.configFile."waybar" = {
		source = ../../../files/waybar;
		recursive = true;
	};
}
