{ pkgs, ... }:

{
	programs.micro = {
		enable = true;
		settings = {
			clipboard = "external";
		};
	};

	home.sessionVariables = {
		MICRO_TRUECOLOR = "1";
	};
}
