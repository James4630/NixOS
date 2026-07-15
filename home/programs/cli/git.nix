{ pkgs, ... }:

{
	programs.git = {
		settings = {
			credential.helper = "libsecret";
			init.defaultBranch = "main";
		};
	};
}
