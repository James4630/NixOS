{
	services.openssh = {
		enable = true;
		settings = {
			PasswordAuthentication = false;
			PermitRootLogin = "no";
			MaxAuthTries = 3;
			PerSourcePenalties = "crash:3600s authfail:3600s max:86400s";
		};
	};
}
