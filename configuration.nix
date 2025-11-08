{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./modules/homepage.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;


  networking.hostName = "monolith";

  time.timeZone = "Europe/Berlin";


  users.users.james = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      tree
    ];
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICfFeHauUkhblLMcVmf4TsxMtEH1x3i2GVCedukfFPUZ archmx@archercamp" ];
  };


  environment = {
  	systemPackages = with pkgs; [
  		fastfetch
  		wget
  		powertop
  		pciutils
  		micro
  		tmux
  		beets
  		kid3-cli
  		progress
  		git
  	];
  	variables = {
  		EDITOR = "micro";
  		BEETSDIR = "/var/lib/beets/";
  	};
  };

  nix.settings = {
  	experimental-features = [ "nix-command" "flakes" ];
  };


  #services
  services = {
  
  	openssh.enable = true;

  	immich = {
  		enable = true;
  		port = 2283;
  		host = "0.0.0.0";
  		openFirewall = true;
  		mediaLocation = "/mnt/storage/immich";
  		accelerationDevices = null; #all devices
  	};

  	caddy = {
  		enable = true;
  		virtualHosts."immich.elliotkirby.de".extraConfig = ''
  		  reverse_proxy :2283
  		'';
  		virtualHosts."elliotkirby.de".extraConfig = ''
  		  reverse_proxy :8082
  		'';
  		virtualHosts."navidrome.elliotkirby.de".extraConfig = ''
  		  reverse_proxy :4533
  		'';
  		virtualHosts."slskd.elliotkirby.de".extraConfig = ''
  		  reverse_proxy :5030
  		'';
  		virtualHosts."lidarr.elliotkirby.de".extraConfig = ''
  		  reverse_proxy :8686
  		'';
  		virtualHosts."bin.elliotkirby.de".extraConfig = ''
  		  reverse_proxy :8087
  		'';
  		virtualHosts."ntfy.elliotkirby.de".extraConfig = ''
  		  reverse_proxy :2586
  		'';
  		virtualHosts."bitwarden.elliotkirby.de".extraConfig = ''
  		  encode zstd gzip

  		  reverse_proxy :${toString config.services.vaultwarden.config.ROCKET_PORT} {
  		  	header_up X-Real-IP {remote_host}
  		  }
  		'';
  		
  		#handle unix sockets for seafile
  		  virtualHosts."seafile.elliotkirby.de".extraConfig = ''
  		    handle_path /seafhttp* {
  		      reverse_proxy {
  		        to unix//run/seafile/server.sock
  		        transport http {
  		          dial_timeout 30s
  		          read_timeout 18000s
  		          write_timeout 18000s
  		        }
  		        header_up X-Forwarded-For {remote_host}
  		        header_up X-Forwarded-Proto {scheme}
  		      }
  		    }
  		
  		    handle {
  		      reverse_proxy {
  		        to unix//run/seahub/gunicorn.sock
  		        transport http {
  		          dial_timeout 30s
  		          read_timeout 1200s
  		          write_timeout 1200s
  		        }
  		        header_up Host {host}
  		        header_up X-Real-IP {remote_host}
  		        header_up X-Forwarded-For {remote_host}
  		        header_up X-Forwarded-Proto {scheme}
  		      }
  		    }

  		    handle_path /seafdav* {
  		    	reverse_proxy :8080/seafdav
  		    }
  		  '';
  	};

  	nginx = {
  		enable = false; #needed because slskd starts it
  	};

  	vaultwarden = {
  		enable = true;
  		backupDir = "/mnt/storage/vaultwarden/backup";
  		environmentFile = "/var/lib/vaultwarden/vaultwarden.env";

  		config = {
  			DOMAIN = "https://bitwarden.elliotkirby.de";
  			SIGNUPS_ALLOWED = false;

  			ROCKET_ADDRESS = "127.0.0.1";
  			ROCKET_PORT = 8222;
  			ROCKET_LOG = "critical";
  		};
  	};

  	seafile = {
  		enable = true;

  		adminEmail = "mail@elliotkirby.de";
  		initialAdminPassword = "change later";

  		ccnetSettings.General = {
  			SERVICE_URL = "https://seafile.elliotkirby.de";

  			#not workking
  			#MEDIA_ROOT = "/var/lib/seafile/seahub/media_custom/";
  		};

  		seafileSettings = {
  			fileserver = {
  				host = "unix:/run/seafile/server.sock";#uses socket for communication instead of TCP (default from wiki)
  				web_token_expire_time = 18000;
  			};
  		};

  		dataDir = "/var/lib/seafile/data";

  		gc = {
  			enable = true;
  			dates = [ "Sun 03:00:00" ];
  		};
  	};

  	navidrome = {
  		enable = true;
  		settings = {
  			Port = 4533;
  			Address = "127.0.0.1";
  			BaseUrl = "https://navidrome.elliotkirby.de";
  			
  			MusicFolder = "/mnt/storage/music";
  			#CoverArtPriority = "cover.*";
  			#ImageCacheSize = "0"; #temporary disable cache (does this remove old cache?)
  			
  			LastFM.ApiKey = "253a63edea1595974207918025405555";
  			LastFM.Secret = "16b6a2f036afe5d88e0da94b52c8902d";
  			Spotify.ID = "0205990c8b994e0b801d68e94bcf77dc";
  			Spotify.Secret = "40c02f1bbdb04ec099aa5bcbcd33172c";
  		};
  		openFirewall = true;
  	};

  	slskd = {
  		enable = true;
  		settings = {
  			web = {
  				url_base = "/";
  				port = 5030;
  				https.disabled = false;
  				authentication.api_keys = {
  					homepage_widget = {
  						key = "WVxrJQ349lG9tLVrk7/OTILKRGWCE+0ldQrRu56KCdVUVhSHEGmcjd1luJqIXY5l";
  						role = "readonly";
  					};
  					soularr = {
  						key = "3tvVl9hyeTJowxTJZJyJOwKw9NX26JY1S/9HzyNNH7JlEc5uFuduumxkZW5PMcPl";
  					};
  				};
  			};
  			soulseek.description = ''
  			Just started with selfhosting Music
  			All tracks are in FLAC 16 bit/44.1kHz except a few niche releases only available as mp3

  			[Software Stack]
  			lidarr + soularr + slskd + navidrome + symfonium
  			Fully serverside so sadly no Musicbrainz Picard for me :( (i could mount the network drive from my server tough)
  			Waiting for Sonic Analysis on Navidrome via AudioMuse
  			'';
  			shares.directories = [ "/mnt/storage/music" ];
  			directories = {
  				downloads = "/mnt/storage/slskd/downloads";
  				incomplete = "/mnt/storage/slskd/incomplete";
  			};
  		};
  		domain = "slskd.elliotkirby.de";
  		openFirewall = true;
  		environmentFile = "/var/lib/slskd/slskd.env";
  	};

  	lidarr = {
  		enable = true;
  		settings = {
  			server.port = 8686;
  		};
  		openFirewall = true;
  	};

  	microbin = {
  		enable = true;
  		settings = {
  			MICROBIN_PORT = 8087;
  			MICROBIN_BIND = "127.0.0.1";
  			MICROBIN_PUBLIC_PATH = "https://bin.elliotkirby.de";

  			MICROBIN_ADMIN_USERNAME = "James";
  			MICROBIN_ADMIN_PASSWORD = "James2008";

  			MICROBIN_HIDE_HEADER = false;
  			MICROBIN_HIDE_FOOTER = true;
  			MICROBIN_HIDE_LOGO = true;

  			MICROBIN_GC_DAYS = 0; #disables GC; GC would remove all "never expire" pastes

  			MICROBIN_ENABLE_BURN_AFTER = true;
  			MICROBIN_QR = true;
  			MICROBIN_ETERNAL_PASTA = true;
  			MICROBIN_HIGHLIGHTSYNTAX = true;
  			MICROBIN_PRIVATE = true;
  			MICROBIN_EDITABLE = true;
  			MICROBIN_SHOW_READ_STATS = true;
  			MICROBIN_ENABLE_READONLY = true;
  		};
  	};
  	
  	
  };


  users.users = {
  	immich.extraGroups = [ "video" "render" ];
  	caddy.extraGroups = [ "seafile" ];
  };

  users.groups.music.members = [ "navidrome" "slskd" "lidarr" ];
  users.groups.beets.members = [ "james" "lidarr" ];

  hardware.graphics = {
  	enable = true;
  	extraPackages = with pkgs; [
  		intel-vaapi-driver
  	];
  };

  #force write access to /mnt/storage/
  systemd.services =
  	let
  	  readWriteOverwrite = {
  	  	serviceConfig = {
  	  		ProtectHome = lib.mkForce "no";
  	  		ProtectSystem = lib.mkForce "no";
  	  		ReadOnlyPaths = lib.mkForce [ ];
  	  	};
  	  };
  	in
  	{
  	slskd = {
  		serviceConfig = (readWriteOverwrite.serviceConfig // {
  			ReadWritePaths = lib.mkForce [ "/mnt/storage/slskd/downloads" "/mnt/storage/slskd/incomplete" ];
  		});
  	};
  	lidarr = {
  		serviceConfig = (readWriteOverwrite.serviceConfig // {
  			ReadWritePaths = lib.mkForce [ "/mnt/storage/slskd/downloads" ];
  		});
  	};
  	"soularr" = {
  		serviceConfig = {
  			Type = "oneshot";
  			User = "root";
  			WorkingDirectory = "/home/james/system-config/pkgs/soularr";
  			ExecStart = "${pkgs.sudo}/bin/sudo bash /home/james/system-config/scripts/start-soularr.sh";
  			Environment = "PATH=/run/current-system/sw/bin:/run/current-system/sw/sbin:/run/current-system/profile/bin";
  		};
  	};
  };

  systemd.timers = {
  	"soularr" = {
  		wantedBy = [ "timers.target" ];
  		  timerConfig = {
  		  	OnBootSec = "15m";
  		  	OnUnitActiveSec = "30m";
  		  	AccuracySec = "1m";
  		  	Persistend = false;
  		  	Unit = "soularr.service";
  		  };
  	};
  };

  security = {
  	sudo.extraConfig = ''
  	  Defaults env_keep += "BEETSDIR"
  	'';
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];


  system.stateVersion = "25.05"; # Did you read the comment?

}
