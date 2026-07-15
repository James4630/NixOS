{ pkgs, ... }:

{
	programs.alacritty = {
		enable = true;
		theme = "tokyo_night_storm";
		settings = {
			window = {
				opacity = 0.7;
				class = {
					general = "Alacritty";
					instance = "Alacritty";
				};
			};
			colors = {
				transparent_background_colors = true;
			};
		};
	};
}
