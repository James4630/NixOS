{ inputs, pkgs, ... }:

{
	services.mako = {
		enable = true;
		
		settings = {
			"actionable=true" = {
			  anchor = "top-right";
			};
			"mode=do-not-disturb" = {
			  invisible = true;
			};
			actions = true;
			anchor = "top-right";
			background-color = "#000000";
			border-color = "#FFFFFF";
			border-radius = 0;
			default-timeout = 5000;
			font = "monospace 10";
			height = 100;
			icons = true;
			ignore-timeout = false;
			layer = "top";
			margin = 10;
			markup = true;
			width = 300;
		};
	};
}
