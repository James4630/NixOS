{ pkgs, ... }:

{
	programs.git = {
		enable = true;
		package = pkgs.git.override { withLibsecret = true; };
		config.user = {
			name = "James4630";
			email = "mail@elliotkirby.de";
		};
	};
}
