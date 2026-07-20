{
	networking = {
		firewall.enable = true;

		nameservers = [ "192.168.20.70" "1.1.1.1" ];
		
		networkmanager = {
			enable = true;
			unmanaged = [
				"interface-name:wg0"
			];
		};
	};

	systemd.network = {
		enable = true;
	};

	programs.nm-applet.enable = true;

	users.users.james.extraGroups = [ "networkmanager" ];
}
