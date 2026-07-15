{ inputs, pkgs, ... }:

{
	programs.hyprlock = {
		enable = true;
		settings = {
		
			general = {
				hide_cursor = true;
				ignore_empty_input = true;
			};
			
			animations = {
				enabled = true;
				fade_in = {
					duration = 300;
					bezier = "easeOutQuint";
				};
				fade_out = {
					duration = 300;
					bezier = "easeOutQuint";
				};
			};

			background = [
				{
					path = "/home/james/systemconfig/files/wallpapers/trauma-team-cyberpunk-2077-comic-3.png";
					monitor = "";
				}
			];

			input-field = [
				{
					size = "200, 50";
					position = "0, -80";
					monitor = "";
					dots_center = true;
					fade_on_empty = false;
					font_color = "rgb(202, 211, 245)";
					inner_color = "rgb(91, 96, 120)";
					outer_color = "rgb(24, 25, 38)";
					outline_thickness = 5;
					shadow_passes = 2;
				}
			];
			
		};
	};
}
