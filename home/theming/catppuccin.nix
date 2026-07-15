{ inputs, pkgs, ... }:

{
	catppuccin = {
		enable = true;
		autoEnable = false;
		flavor = "macchiato";
		accent = "lavender";

		micro = {
			enable = true;
			transparent = true;
		};
		fuzzel.enable = true;
		mako.enable = true;
		wlogout.enable = true;
	};
}
