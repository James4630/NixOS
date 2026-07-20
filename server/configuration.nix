{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./modules/homepage.nix
      ./modules/minecraft-servers.nix
    ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
  	"minecraft-server"
  	"intel-ocl"
  ];
  
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "lateralus";
  networking.nameservers = [ "192.168.20.70" "1.1.1.1" ];

  time.timeZone = "Europe/Berlin";

  fileSystems."/mnt/media" =
    { device = "/dev/disk/by-uuid/63e3e406-91c8-459c-81df-1e6b42b5a847";
      fsType = "ext4";
    };

  fileSystems."/mnt/storage" =
    { device = "/dev/disk/by-uuid/f2469dac-7c28-4baf-a5ce-3570d5601b8d";
      fsType = "ext4";
    };

  users.users.james = {
    isNormalUser = true;
    extraGroups = [ "wheel" "minecraft" ];
    packages = with pkgs; [
      tree
    ];
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICfFeHauUkhblLMcVmf4TsxMtEH1x3i2GVCedukfFPUZ archmx@archercamp" ];
  };


  environment = {
  	systemPackages = with pkgs; [
  		fastfetch
  		wget
  		htop
  		powertop
  		pciutils
  		micro
  		beets
  		kid3-cli
  		progress
  		git
  		dotnet-sdk_9
  		ncdu
  		rsync

  		jellyfin
  		jellyfin-web
  		jellyfin-ffmpeg
  	];
  	variables = {
  		EDITOR = "micro";
  		BEETSDIR = "/var/lib/beets/";
  	};
  };

  nix.settings = {
  	experimental-features = [ "nix-command" "flakes" ];
  };

  programs = {
  	tmux = {
  		enable = true;
  		terminal = "tmux-256color";
  		clock24 = true;
  		plugins = with pkgs.tmuxPlugins; [
  			resurrect
  		];
  		extraConfig = "set -g @resurrect-capture-pane-contents 'on'";
  	};
  };

  services = {
  
  	openssh.enable = true;
  	#openssh.settings.PermitRootLogin = "yes";

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
  		virtualHosts."jellyfin.elliotkirby.de".extraConfig = ''
  		  reverse_proxy :8096
  		'';
  		virtualHosts."jellyseerr.elliotkirby.de".extraConfig = ''
  		  reverse_proxy :5055
  		'';
  		virtualHosts."radarr.elliotkirby.de".extraConfig = ''
  		  reverse_proxy :7878
  		'';
  		virtualHosts."sonarr.elliotkirby.de".extraConfig = ''
  		  reverse_proxy :8989
  		'';
  		virtualHosts."prowlarr.elliotkirby.de".extraConfig = ''
  		  reverse_proxy :9696
  		'';
  		virtualHosts."rdtc.elliotkirby.de".extraConfig = ''
  		  reverse_proxy :6500
  		'';
  		virtualHosts."bazarr.elliotkirby.de".extraConfig = ''
  		  reverse_proxy :6767
  		'';
  		virtualHosts."gotify.elliotkirby.de".extraConfig = ''
  		  reverse_proxy :26269
  		'';
  		virtualHosts."filebrowser.elliotkirby.de".extraConfig = ''
  		  reverse_proxy :9089
  		'';
  		virtualHosts."bitwarden.elliotkirby.de".extraConfig = ''
  		  encode zstd gzip

  		  reverse_proxy :${toString config.services.vaultwarden.config.ROCKET_PORT} {
  		  	header_up X-Real-IP {remote_host}
  		  }
  		'';
  		
  		#handle unix sockets for seafile
  		  #virtualHosts."seafile.elliotkirby.de".extraConfig = ''
  		  #  handle_path /seafhttp* {
  		  #    reverse_proxy {
  		  #      to unix//run/seafile/server.sock
  		  #      transport http {
  		  #        dial_timeout 30s
  		  #        read_timeout 18000s
  		  #        write_timeout 18000s
  		  #      }
  		  #      header_up X-Forwarded-For {remote_host}
  		  #      header_up X-Forwarded-Proto {scheme}
  		  #    }
  		  #  }
  		
  		  #  handle {
  		  #    reverse_proxy {
  		  #      to unix//run/seahub/gunicorn.sock
  		  #      transport http {
  		  #        dial_timeout 30s
  		  #        read_timeout 1200s
  		  #        write_timeout 1200s
  		  #      }
  		  #      header_up Host {host}
  		  #      header_up X-Real-IP {remote_host}
  		  #      header_up X-Forwarded-For {remote_host}
  		  #      header_up X-Forwarded-Proto {scheme}
  		  #    }
  		  #  }

  		  #  handle_path /seafdav* {
  		  #  	reverse_proxy :8080/seafdav
  		  #  }
  		  #'';
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

  	#seafile = {
  	#	#
  	#	enable = true;
#
 # 		adminEmail = "mail@elliotkirby.de";
  #		initialAdminPassword = "change later";
#
 # 		ccnetSettings.General = {
  #			SERVICE_URL = "https://seafile.elliotkirby.de";
#
 # 			#not workking
  #			#MEDIA_ROOT = "/var/lib/seafile/seahub/media_custom/";
  #		};
#
 # 		seafileSettings = {
  #			fileserver = {
  #				host = "unix:/run/seafile/server.sock";#uses socket for communication instead of TCP (default from wiki)
  #				web_token_expire_time = 18000;
  #			};
  #		};
#
 # 		dataDir = "/mnt/storage/seafile/data";
#
 # 		gc = {
  #			enable = true;
  #			dates = [ "Sun 03:00:00" ];
  #		};
  #	};

  	navidrome = {
  		enable = true;
  		settings = {
  			Port = 4533;
  			Address = "127.0.0.1";
  			BaseUrl = "https://navidrome.elliotkirby.de";
  			
  			MusicFolder = "/mnt/storage/music";
  			#CoverArtPriority = "cover.*";
  			#ImageCacheSize = "0"; #temporary disable cache (does this remove old cache?)

  			#Backup = {
  			#	Path = "/mnt/backup/appdata/navidrome";
  			#	Count = 3;
  			#	Schedule = "0 0 * * *";
  			#};

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
  			Most tracks are in FLAC 16 bit/44.1kHz

  			lidarr + soularr + slskd + navidrome + symfonium
  			
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

  	jellyfin = {
  		enable = true;
  	};
  	
  	jellyseerr = {
  		enable = true;
  	};

  	radarr = {
  		enable = true;
  	};

  	sonarr = {
  		enable = true;
  	};

  	prowlarr = {
  		enable = true;
  	};

  	bazarr = {
  		enable = true;
  	};

  	gotify = {
  		enable = true;
  		environment = {
  			GOTIFY_SERVER_PORT = 26269;
  		};
  	};

  	filebrowser = {
  		enable = true;
  		settings = {
  			port = 9089;
  			#address = "filebrowser.elliotkirby.de";
  			root = "/mnt/media/movies";
  		};
  	};
  	
  };
  
  users = {
  	users = {
  		rdtc = {
  			group = "rdtc";
  			isSystemUser = true;
  			home = "/var/lib/rdtc";
  			createHome = true;
  		};
  		immich.extraGroups = [ "video" "render" ];
  		jellyfin.extraGroups = [ "video" "render" ];
  		caddy.extraGroups = [ "seafile" ];
  	};
  	
  	groups = {
  		"rdtc" = {};
  		"torrents" = {};
  		music.members = [ "navidrome" "slskd" "lidarr" ];
  		media.members = [ "jellyfin" "radarr" "sonarr" ];
  		#torrents.members = [ "rdtc" ];
  		beets.members = [ "james" "lidarr" ];
  	};
  };

  hardware.graphics = {
  	enable = true;
  	extraPackages = with pkgs; [
  		intel-ocl
  		intel-vaapi-driver
  		libva-vdpau-driver
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
  	jellyfin = {
  		serviceConfig = (readWriteOverwrite.serviceConfig // {
  			ReadWritePaths = lib.mkForce [ "/mnt/media" "/mnt/storage/media" ];
  		});
  	};
  	radarr = {
  		serviceConfig = (readWriteOverwrite.serviceConfig // {
  			ReadWritePaths = lib.mkForce [ "/mnt/media" "/mnt/storage/media" ];
  		});
  	};
  	sonarr = {
  		serviceConfig = (readWriteOverwrite.serviceConfig // {
  			ReadWritePaths = lib.mkForce [ "/mnt/media" "/mnt/storage/media" ];
  		});
  	};
  	"soularr" = {
  		serviceConfig = {
  			Type = "oneshot";
  			User = "root";
  			WorkingDirectory = "${./pkgs/soularr}";
  			ExecStart = "${pkgs.sudo}/bin/sudo bash ${./scripts/start-soularr.sh}";
  			Environment = "PATH=/run/current-system/sw/bin:/run/current-system/sw/sbin:/run/current-system/profile/bin";
  		};
  	};
  	"rdtc" = {
  		wantedBy = [ "multi-user.target" ];
  		serviceConfig = {
  			User = "rdtc";
  			WorkingDirectory = "/var/lib/rdtc/rdtc";
  			ExecStart = "${pkgs.dotnet-sdk_9}/bin/dotnet /var/lib/rdtc/rdtc/RdtClient.Web.dll";
  		};
  	};
  };

  systemd.timers = {
  	"soularr" = {
  		wantedBy = [ "timers.target" ];
  		  timerConfig = {
  		  	OnBootSec = "10m";
  		  	OnUnitActiveSec = "15m";
  		  	AccuracySec = "1m";
  		  	Persistent = false;
  		  	Unit = "soularr.service";
  		  };
  	};
  };

  security = {
  	sudo = {
  		extraConfig = ''
  		  Defaults env_keep += "BEETSDIR"
  		'';
  		extraRules = [
  			{
  				users = [ "minecraft" ];
  				commands = [
  					{ command = "/bin/systemctl start minecraft-server-*.service"; options = [ "NOPASSWD" ]; }
  					{ command = "/bin/systemctl stop minecraft-server-*.service"; options = [ "NOPASSWD" ]; }
  				];
  			}
  		];
  	};
  	
  	polkit = {
  		enable = true;
  		extraConfig = ''
  		  polkit.addRule(function(action, subject) {
  		    var allowedUser = "minecraft";

  		    var allowedServices = [
  		      "minecraft-server-lobby.service",
  		      "minecraft-server-survival_fabric.service",
  		      "minecraft-server-forever_world.service",
  		      "minecraft-server-clashcraft.service",
  		      "minecraft-server-public_lobby.service",
  		      "minecraft-server-public_test.service"
  		    ];

  		    if (
  		      subject.user == allowedUser &&
  		      action.id == "org.freedesktop.systemd1.manage-units"
  		    ) {
  		      var unit = action.lookup("unit");

  		      if (allowedServices.indexOf(unit) >= 0) {
  		        return polkit.Result.YES;
  		      }
  		    }
  		    return polkit.Result.NOT_HANDLED;
  		  });
  		'';
  	};
  };


  networking.firewall.allowedTCPPorts = [ 80 443 25565 25566 25575 25577 7359 ];


  system.stateVersion = "25.05"; # Did you read the comment?

}
