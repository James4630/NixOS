{ config, lib, pkgs, inputs, ... }:

{
	age.secrets.wg_fritzbox = {
		file = ../../secrets/wg_fritzbox.age;
		mode = "640";
		owner = "systemd-network";
		group = "systemd-network";
	};
	
	systemd.network = {
		wait-online.enable = false;

		netdevs."50-wg0" = {
			netdevConfig = {
				Kind = "wireguard";
				Name = "wg0";
			};

			wireguardConfig = {
				PrivateKeyFile = config.age.secrets.wg_fritzbox.path;
				RouteTable = "main";
				FirewallMark = 42;
			};

			wireguardPeers = [
				{
					PublicKey = "kVHdOlPHGWxST2yd/kavJOPO4o+vsuPOMsXtwVVY4H8=";
					AllowedIPs = [ "192.168.178.0/24" "0.0.0.0/0" "fd6c:9370:db23::/64" "::/0" ];
					Endpoint = "cz99gi6emx648lg4.myfritz.net:55327";
					PersistentKeepalive = 25;
				}
			];
		};

		networks."50-wg0" = {
			matchConfig.Name = "wg0";
			address = [ "192.168.178.202/24" "fd6c:9370:db23::202/64" ];
			linkConfig = {
				ActivationPolicy = "down";
				RequiredForOnline = false;
			};
		};
		
	};
}
