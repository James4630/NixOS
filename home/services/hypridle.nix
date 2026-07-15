{ inputs, pkgs, ... }:

{
	services.hypridle = {
		enable = true;
		
		settings = {
			general = {
				ignore_dbus_inhibit = false;
				lock_cmd = "pidof hyprlock || hyprlock";
			};
			listener = [
				{
					timeout = 300;
					on-timeout = "pidof hyprlock || hyprlock";
				}
				{
					timeout = 600;
					on-timeout = "niri msg action power-off-monitors";
					on-resume = "niri msg action power-on-monitors";
				}
			];
		};
	};
}
