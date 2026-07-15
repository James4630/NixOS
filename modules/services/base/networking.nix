{
	networking = {
		firewall.enable = true;
		
		networkmanager = {
			enable = true;
			unmanaged = [
				"interface-name:wg0"
			];
		};
	};

	programs.nm-applet.enable = true;

	users.users.james.extraGroups = [ "networkmanager" ];
}
