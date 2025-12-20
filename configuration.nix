{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./modules/homepage.nix
      inputs.nix-minecraft.nixosModules.minecraft-servers
    ];

  nixpkgs.overlays = [
  	inputs.nix-minecraft.overlay
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
  	"minecraft-server"
  	"intel-ocl"
  ];
  
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;


  networking.hostName = "monolith";

  time.timeZone = "Europe/Berlin";


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
  		powertop
  		pciutils
  		micro
  		tmux
  		beets
  		kid3-cli
  		progress
  		git
  		dotnet-sdk_9

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

  	minecraft-servers = {
  		enable = true;
  		eula = true;
  		openFirewall = false;

  		servers = {
  			survival_fabric = {
  				enable = true;
  				autoStart = false; #started by velocity
  				restart = "no";
  				package = pkgs.fabricServers.fabric-1_21_10;

  				whitelist = {
  					CreepedCraft = "14f2be87-7ab3-4662-9b0d-80ddfbef73a5";
  					flycraft2000 = "51a935e7-6524-4177-bd80-1504aa3dc31b";
  				};
  				operators = {
  					SpatialComputing = {
  						uuid = "ee2c78e1-11c7-4cb3-bebc-a3b2c119abf3";
  						level = 4;
  						bypassesPlayerLimit = true;
  					};
  				};
  				serverProperties = {
  					server-port = 25545;
  					online-mode = false; #allow velocity to connect
  					difficulty = "hard";
  					gamemode = "survival";
  					force-gamemode = true;
  					level-seed = "42";
  					simulation-distance = 8;
  					view-distance = 8; #low to save bandwith; DH sends 256 chunks distance as LODs
  					spawn-protection = 1;
  					max-players = 20;
  					motd = "Survival♥";
  					white-list = true;
  					enable-rcon = true;
  					"rcon.password" = "James2008"; #lol i should put this in a secret
  					"rcon.port" = 25575; #default
  					"broadcast-rcon-to-ops" = true;
  				};

  				jvmOpts = "-Xms8192M -Xmx8192M -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:+DisableExplicitGC ";
  				
  				symlinks = {
  					mods = pkgs.linkFarmFromDrvs "mods" (builtins.attrValues {
  						FabricAPI = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/UuXf1NbU/fabric-api-0.138.0+1.21.10.jar"; sha512 = "2frq0x18fjr7aimlpn1mr0w16wmxzvc46wrcz4bf8kj7j84qcw91rvzshdpwhb34fj08155a8vb3m13mjp8gpjc6j2z11w2rm7hqgkj"; };
  						JustPlayerHeads = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/YdVBZMNR/versions/XSCScrV7/justplayerheads-1.21.10-4.3.jar"; sha512 = "1zgf6apfgxpb6snj8vbm6hykb3jc1n7h3nlymdk3lqqyar9d3kpg71a55pbphby90g7fmv0cypn47rzr9mj3gs5g0n4086mqm55fnq6"; };
  						JustMobHeads = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/jzTUm9hE/versions/XBRiGW8q/justmobheads-1.21.10-8.9.jar"; sha512 = "3y63apg3gw3nswh23zhf7a43yp14n9zprmcgbg1rjsvr3zrvmmpzm65g236xw0s2271ld1agxajj9m71s8x5gwsav2f3r9a0wh7fjg5"; };
  						InvisibleFrames = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/QD87oMUf/versions/S48QrgU7/invisibleframes-1.5.0+1.21.6.jar"; sha512 = "1w99h02l9yja7q62d3l6h2f49irif74s1fm4isz889ax626zr4p3gw37sy62p0fw3kn7fhh40c67bm3gzqgkr2xpac9ah7z29z3lxid"; };
  						ScalableLux = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/Ps1zyz6x/versions/PV9KcrYQ/ScalableLux-0.1.6+fabric.c25518a-all.jar"; sha512 = "3kjl11p15xh80mk61ggz3q32zvc7nzynhh5hf2vpmf3fl8q3qhx10pdqyxqz71829dvirr8k77n95nvgm4b64jgf36xky2wwz0ib5bj"; };
  						Chunky = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/fALzjamp/versions/kkEljQ4R/Chunky-Fabric-1.4.51.jar"; sha512 = "3lv6whg1v3na21v5mkgprv4g93bx2n8nbdc51l3xwkalr62h3acg28wa3ggh8hsf5hjcvcwl27hmrgism5v34zb0brcv2k1wxy1xgx9"; };
  						AlternateCurrent = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/r0v8vy1s/versions/FY6xclLZ/alternate-current-mc1.21.9-1.9.0.jar"; sha512 = "0qa50wa2gc5m5rm62907p88sk9jf18pqvv83cqnfnlx11xcirn7nr087sh3d1fdcyn1ni6fcdmvgimslll6yi7mskj5z8a04j6l54rx"; };
  						Clumps = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/Wnxd13zP/versions/8BikzIOh/Clumps-fabric-1.21.10-28.0.0.1.jar"; sha512 = "20m19acybva37zrqz9bhpadwx1p49654n2xx3vj4l1ik7nwsrxym72s9cjski3w9ryqgzjakpnjfb0im5xq32yrclrj52cf1pzh3237"; };
  						C2Me = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/VSNURh3q/versions/uNick7oj/c2me-fabric-mc1.21.10-0.3.5.1.0.jar"; sha512 = "3dw81yqjkl3v6lbj1549y4srfzbxzclyaigmgkgrxm6xs3iw1sdhnwr3673hf6ai69q8p0jywk8c5shf2f71s69lrjzs45r5a3rq1sd"; };
  						DistantHorizons = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/uCdwusMi/versions/9Y10ZuWP/DistantHorizons-2.3.6-b-1.21.10-fabric-neoforge.jar"; sha512 = "3ya2x30aickp5iypr0rrbh1gj2smwbg49mcgp41cj6ijxlnhxcx4z17xynzv8xbj5pbaqf50zs9ay7ad0p3zyprlm9d3432xjvp06qv"; };
  						NetherPortalFix = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/nPZr02ET/versions/EQ03E7hB/netherportalfix-fabric-1.21.10-21.10.1.jar"; sha512 = "2c9dm0p3yba9a9nr5qnrlajifp544hcjm9rkxmfp191zbza6qs22gqw58r73q194qf1r42lsaqs1dfdk5hljjks934g54yfqilqb3bf"; };
  						WTHIT = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/6AQIaxuO/versions/4ytH5lRo/wthit-1.21.10-fabric-17.3.2.jar"; sha512 = "02ngc0vwrk8psq41ys4sm6p7rrmn1jlry05rpb3p8m7xs1iarm057yy20aks92fs323ang2gdw67pjq2qljqxyapwdxv79vvr8wci8y"; };
  						AppleSkin = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/EsAfCjCV/versions/8sbiz1lS/appleskin-fabric-mc1.21.9-3.0.7.jar"; sha512 = "224a3qhcq3a5z5cd3q8pcxlhzi81c89k51xxdbqifjrscmdc72hwrkiw5s9253vck58bd5y903ccis1amqwvcblryvwsh4il2sd1l3r"; };
  						XaerosWorldMap = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/NcUtCpym/versions/81Qc21E2/XaerosWorldMap_1.39.17_Fabric_1.21.9.jar"; sha512 = "39d0j50rlprv6mga4p8l3085d35pcsxiygz11sl0kr1qk4s73nypac84idwf9m9njgqgwrpnxxs7047lshsqxdqx6y3nhphd9hps3g6"; };
  						FerriteCore = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/uXXizFIs/versions/MGoveONm/ferritecore-8.0.2-fabric.jar"; sha512 = "3nbxsb8kmv95l3zz9xcxicsc4x7a02wplqfkxwb7gm5rgpd5xw9r80mrxpflhzyfbkp5k44smyvikzy3c6ym0zlyn0zdykd27xr0f4c"; };
  						Lithium = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/oGKQMdyZ/lithium-fabric-0.20.0+mc1.21.10.jar"; sha512 = "393wcqdscp9dhpjnklacfvr8rcpzs17q4py6ap7igx8k8126ysmvn7h0inksg1a9ia2rp3bipyyrrnws4in1k1nv728mwznqw7hwp3m"; };
  						BadPackets = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/ftdbN0KK/versions/bJjBP5HF/badpackets-fabric-0.10.2.jar"; sha512 = "08vh2fi9s6qjya1flfmkqyvfdvl11hh5zf8bw2h3sik97c7p90pyy8a04zca5hn3cn0aa059pa7pj0jd5nqv8y1bhl9ywk2xylzk1n2"; };
  						Balm = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/MBAkmtvl/versions/yJmabsVx/balm-fabric-1.21.10-21.10.7.jar"; sha512 = "2xq4gl7jpba8zkms2gdfka0x9ks4fa62ni7z8j25jary1j68jc7d4cvaa0kpkvz530qsn0csndzdri2vv25fbqygwrv4i7vy7dcmcpk"; };
  						Collective = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/e0M1UDsY/versions/A0CFMmGr/collective-1.21.10-8.13.jar"; sha512 = "0wy21xaic50mpaya2mmxhv40c2p8s50d5qr5zs66xak1c7bxqj7dfnnipfz0fpf4wnrfrdy9pg080mrzkqy63dmi339iaw57ig4ym01"; };
  						FabricProxyLite = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/8dI2tmqs/versions/nR8AIdvx/FabricProxy-Lite-2.11.0.jar"; sha512 = "c2e1d9279f6f19a561f934b846540b28a033586b4b419b9c1aa27ac43ffc8fad2ce60e212a15406e5fa3907ff5ecbe5af7a5edb183a9ee6737a41e464aec1375"; };
  						VoiceChat = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/BjR2lc4k/voicechat-fabric-1.21.10-2.6.6.jar"; sha512 = "fc0b838a0906ddafeabf9db3b459d4226a2f06458443ee1dee44d937e5896f0d8d3e7c7bbc2a93ea74b4665f37249e7da719bbabf8449c756d2a49116be61197"; };
  					});
  				};
  			};

  			forever_world = {
  				enable = true;
  				autoStart = false; #started by velocity
  				restart = "no";
  				package = pkgs.fabricServers.fabric-1_21_10;

  				whitelist = {
  					CreepedCraft = "14f2be87-7ab3-4662-9b0d-80ddfbef73a5";
  					flycraft2000 = "51a935e7-6524-4177-bd80-1504aa3dc31b";
  				};
  				operators = {
  					SpatialComputing = {
  						uuid = "ee2c78e1-11c7-4cb3-bebc-a3b2c119abf3";
  						level = 4;
  						bypassesPlayerLimit = true;
  					};
  				};
  				serverProperties = {
  					server-port = 25546;
  					online-mode = false; #allow velocity to connect
  					difficulty = "hard";
  					gamemode = "survival";
  					force-gamemode = true;
  					level-seed = "forever";
  					simulation-distance = 8;
  					view-distance = 8; #low to save bandwith; DH sends 256 chunks distance as LODs
  					spawn-protection = 1;
  					max-players = 20;
  					motd = "Survival";
  					white-list = true;
  					enable-rcon = false;
  					#"rcon.password" = "James2008"; #lol i should put this in a secret
  					#"rcon.port" = 25575; #default
  					#"broadcast-rcon-to-ops" = true;
  				};

  				jvmOpts = "-Xms8192M -Xmx8192M -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:+DisableExplicitGC ";
  				
  				symlinks = {
  					mods = pkgs.linkFarmFromDrvs "mods" (builtins.attrValues {
  						FabricAPI = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/UuXf1NbU/fabric-api-0.138.0+1.21.10.jar"; sha512 = "2frq0x18fjr7aimlpn1mr0w16wmxzvc46wrcz4bf8kj7j84qcw91rvzshdpwhb34fj08155a8vb3m13mjp8gpjc6j2z11w2rm7hqgkj"; };
  						JustPlayerHeads = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/YdVBZMNR/versions/XSCScrV7/justplayerheads-1.21.10-4.3.jar"; sha512 = "1zgf6apfgxpb6snj8vbm6hykb3jc1n7h3nlymdk3lqqyar9d3kpg71a55pbphby90g7fmv0cypn47rzr9mj3gs5g0n4086mqm55fnq6"; };
  						JustMobHeads = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/jzTUm9hE/versions/XBRiGW8q/justmobheads-1.21.10-8.9.jar"; sha512 = "3y63apg3gw3nswh23zhf7a43yp14n9zprmcgbg1rjsvr3zrvmmpzm65g236xw0s2271ld1agxajj9m71s8x5gwsav2f3r9a0wh7fjg5"; };
  						InvisibleFrames = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/QD87oMUf/versions/S48QrgU7/invisibleframes-1.5.0+1.21.6.jar"; sha512 = "1w99h02l9yja7q62d3l6h2f49irif74s1fm4isz889ax626zr4p3gw37sy62p0fw3kn7fhh40c67bm3gzqgkr2xpac9ah7z29z3lxid"; };
  						ScalableLux = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/Ps1zyz6x/versions/PV9KcrYQ/ScalableLux-0.1.6+fabric.c25518a-all.jar"; sha512 = "3kjl11p15xh80mk61ggz3q32zvc7nzynhh5hf2vpmf3fl8q3qhx10pdqyxqz71829dvirr8k77n95nvgm4b64jgf36xky2wwz0ib5bj"; };
  						Chunky = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/fALzjamp/versions/kkEljQ4R/Chunky-Fabric-1.4.51.jar"; sha512 = "3lv6whg1v3na21v5mkgprv4g93bx2n8nbdc51l3xwkalr62h3acg28wa3ggh8hsf5hjcvcwl27hmrgism5v34zb0brcv2k1wxy1xgx9"; };
  						AlternateCurrent = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/r0v8vy1s/versions/FY6xclLZ/alternate-current-mc1.21.9-1.9.0.jar"; sha512 = "0qa50wa2gc5m5rm62907p88sk9jf18pqvv83cqnfnlx11xcirn7nr087sh3d1fdcyn1ni6fcdmvgimslll6yi7mskj5z8a04j6l54rx"; };
  						Clumps = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/Wnxd13zP/versions/8BikzIOh/Clumps-fabric-1.21.10-28.0.0.1.jar"; sha512 = "20m19acybva37zrqz9bhpadwx1p49654n2xx3vj4l1ik7nwsrxym72s9cjski3w9ryqgzjakpnjfb0im5xq32yrclrj52cf1pzh3237"; };
  						C2Me = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/VSNURh3q/versions/uNick7oj/c2me-fabric-mc1.21.10-0.3.5.1.0.jar"; sha512 = "3dw81yqjkl3v6lbj1549y4srfzbxzclyaigmgkgrxm6xs3iw1sdhnwr3673hf6ai69q8p0jywk8c5shf2f71s69lrjzs45r5a3rq1sd"; };
  						DistantHorizons = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/uCdwusMi/versions/9Y10ZuWP/DistantHorizons-2.3.6-b-1.21.10-fabric-neoforge.jar"; sha512 = "3ya2x30aickp5iypr0rrbh1gj2smwbg49mcgp41cj6ijxlnhxcx4z17xynzv8xbj5pbaqf50zs9ay7ad0p3zyprlm9d3432xjvp06qv"; };
  						NetherPortalFix = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/nPZr02ET/versions/EQ03E7hB/netherportalfix-fabric-1.21.10-21.10.1.jar"; sha512 = "2c9dm0p3yba9a9nr5qnrlajifp544hcjm9rkxmfp191zbza6qs22gqw58r73q194qf1r42lsaqs1dfdk5hljjks934g54yfqilqb3bf"; };
  						WTHIT = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/6AQIaxuO/versions/4ytH5lRo/wthit-1.21.10-fabric-17.3.2.jar"; sha512 = "02ngc0vwrk8psq41ys4sm6p7rrmn1jlry05rpb3p8m7xs1iarm057yy20aks92fs323ang2gdw67pjq2qljqxyapwdxv79vvr8wci8y"; };
  						AppleSkin = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/EsAfCjCV/versions/8sbiz1lS/appleskin-fabric-mc1.21.9-3.0.7.jar"; sha512 = "224a3qhcq3a5z5cd3q8pcxlhzi81c89k51xxdbqifjrscmdc72hwrkiw5s9253vck58bd5y903ccis1amqwvcblryvwsh4il2sd1l3r"; };
  						XaerosWorldMap = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/NcUtCpym/versions/81Qc21E2/XaerosWorldMap_1.39.17_Fabric_1.21.9.jar"; sha512 = "39d0j50rlprv6mga4p8l3085d35pcsxiygz11sl0kr1qk4s73nypac84idwf9m9njgqgwrpnxxs7047lshsqxdqx6y3nhphd9hps3g6"; };
  						FerriteCore = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/uXXizFIs/versions/MGoveONm/ferritecore-8.0.2-fabric.jar"; sha512 = "3nbxsb8kmv95l3zz9xcxicsc4x7a02wplqfkxwb7gm5rgpd5xw9r80mrxpflhzyfbkp5k44smyvikzy3c6ym0zlyn0zdykd27xr0f4c"; };
  						Lithium = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/oGKQMdyZ/lithium-fabric-0.20.0+mc1.21.10.jar"; sha512 = "393wcqdscp9dhpjnklacfvr8rcpzs17q4py6ap7igx8k8126ysmvn7h0inksg1a9ia2rp3bipyyrrnws4in1k1nv728mwznqw7hwp3m"; };
  						BadPackets = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/ftdbN0KK/versions/bJjBP5HF/badpackets-fabric-0.10.2.jar"; sha512 = "08vh2fi9s6qjya1flfmkqyvfdvl11hh5zf8bw2h3sik97c7p90pyy8a04zca5hn3cn0aa059pa7pj0jd5nqv8y1bhl9ywk2xylzk1n2"; };
  						Balm = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/MBAkmtvl/versions/yJmabsVx/balm-fabric-1.21.10-21.10.7.jar"; sha512 = "2xq4gl7jpba8zkms2gdfka0x9ks4fa62ni7z8j25jary1j68jc7d4cvaa0kpkvz530qsn0csndzdri2vv25fbqygwrv4i7vy7dcmcpk"; };
  						Collective = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/e0M1UDsY/versions/A0CFMmGr/collective-1.21.10-8.13.jar"; sha512 = "0wy21xaic50mpaya2mmxhv40c2p8s50d5qr5zs66xak1c7bxqj7dfnnipfz0fpf4wnrfrdy9pg080mrzkqy63dmi339iaw57ig4ym01"; };
  						FabricProxyLite = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/8dI2tmqs/versions/nR8AIdvx/FabricProxy-Lite-2.11.0.jar"; sha512 = "c2e1d9279f6f19a561f934b846540b28a033586b4b419b9c1aa27ac43ffc8fad2ce60e212a15406e5fa3907ff5ecbe5af7a5edb183a9ee6737a41e464aec1375"; };
  						VoiceChat = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/BjR2lc4k/voicechat-fabric-1.21.10-2.6.6.jar"; sha512 = "fc0b838a0906ddafeabf9db3b459d4226a2f06458443ee1dee44d937e5896f0d8d3e7c7bbc2a93ea74b4665f37249e7da719bbabf8449c756d2a49116be61197"; };
  					});
  				};
  			};

  			clashcraft = {
  				enable = true;
  				autoStart = false; #started by velocity
  				restart = "no";
  				package = pkgs.fabricServers.fabric-1_21_10;

  				operators = {
  					SpatialComputing = {
  						uuid = "ee2c78e1-11c7-4cb3-bebc-a3b2c119abf3";
  						level = 4;
  						bypassesPlayerLimit = true;
  					};
  				};
  				serverProperties = {
  					server-port = 25555;
  					online-mode = false; #allow velocity to connect
  					difficulty = "hard";
  					gamemode = "adventure";
  					force-gamemode = true;
  					level-type = "flat";
  					generator-settings = ''{"biome":"minecraft:plains","layers":[]}'';
  					generate-structures = false;
  					function-permission-level = 4;
  					simulation-distance = 4;
  					view-distance = 4;
  					max-players = 42;
  					motd = "ClashCraft";
  					white-list = false;
  					enable-rcon = true;
  					#"rcon.password" = "James2008"; #lol i should put this in a secret
  					#"rcon.port" = 25576;
  					#"broadcast-rcon-to-ops" = true;
  				};

  				jvmOpts = "-Xms4096M -Xmx4096M -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:+DisableExplicitGC ";

  				symlinks = {
  					mods = pkgs.linkFarmFromDrvs "mods" (builtins.attrValues {
  						FabricAPI = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/UuXf1NbU/fabric-api-0.138.0+1.21.10.jar"; sha512 = "2frq0x18fjr7aimlpn1mr0w16wmxzvc46wrcz4bf8kj7j84qcw91rvzshdpwhb34fj08155a8vb3m13mjp8gpjc6j2z11w2rm7hqgkj"; };
  						ScalableLux = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/Ps1zyz6x/versions/PV9KcrYQ/ScalableLux-0.1.6+fabric.c25518a-all.jar"; sha512 = "3kjl11p15xh80mk61ggz3q32zvc7nzynhh5hf2vpmf3fl8q3qhx10pdqyxqz71829dvirr8k77n95nvgm4b64jgf36xky2wwz0ib5bj"; };
  						Clumps = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/Wnxd13zP/versions/8BikzIOh/Clumps-fabric-1.21.10-28.0.0.1.jar"; sha512 = "20m19acybva37zrqz9bhpadwx1p49654n2xx3vj4l1ik7nwsrxym72s9cjski3w9ryqgzjakpnjfb0im5xq32yrclrj52cf1pzh3237"; };
  						C2Me = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/VSNURh3q/versions/uNick7oj/c2me-fabric-mc1.21.10-0.3.5.1.0.jar"; sha512 = "3dw81yqjkl3v6lbj1549y4srfzbxzclyaigmgkgrxm6xs3iw1sdhnwr3673hf6ai69q8p0jywk8c5shf2f71s69lrjzs45r5a3rq1sd"; };
  						FerriteCore = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/uXXizFIs/versions/MGoveONm/ferritecore-8.0.2-fabric.jar"; sha512 = "3nbxsb8kmv95l3zz9xcxicsc4x7a02wplqfkxwb7gm5rgpd5xw9r80mrxpflhzyfbkp5k44smyvikzy3c6ym0zlyn0zdykd27xr0f4c"; };
  						Lithium = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/oGKQMdyZ/lithium-fabric-0.20.0+mc1.21.10.jar"; sha512 = "393wcqdscp9dhpjnklacfvr8rcpzs17q4py6ap7igx8k8126ysmvn7h0inksg1a9ia2rp3bipyyrrnws4in1k1nv728mwznqw7hwp3m"; };
  						XaerosWorldMap = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/NcUtCpym/versions/81Qc21E2/XaerosWorldMap_1.39.17_Fabric_1.21.9.jar"; sha512 = "39d0j50rlprv6mga4p8l3085d35pcsxiygz11sl0kr1qk4s73nypac84idwf9m9njgqgwrpnxxs7047lshsqxdqx6y3nhphd9hps3g6"; };
  						FabricProxyLite = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/8dI2tmqs/versions/nR8AIdvx/FabricProxy-Lite-2.11.0.jar"; sha512 = "c2e1d9279f6f19a561f934b846540b28a033586b4b419b9c1aa27ac43ffc8fad2ce60e212a15406e5fa3907ff5ecbe5af7a5edb183a9ee6737a41e464aec1375"; };
  						VoiceChat = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/BjR2lc4k/voicechat-fabric-1.21.10-2.6.6.jar"; sha512 = "fc0b838a0906ddafeabf9db3b459d4226a2f06458443ee1dee44d937e5896f0d8d3e7c7bbc2a93ea74b4665f37249e7da719bbabf8449c756d2a49116be61197"; };
  					});
  				};
  			};

  			lobby = {
  				enable = true;
  				autoStart = false; #started by velocity
  				restart = "no";
  				package = pkgs.fabricServers.fabric-1_21_10;

  				operators = { SpatialComputing = { uuid = "ee2c78e1-11c7-4cb3-bebc-a3b2c119abf3"; level = 4; bypassesPlayerLimit = true; }; };
  				
  				serverProperties = {
  					server-port = 25535;
  					online-mode = false; #allow velocity to connect
  					difficulty = "hard";
  					gamemode = "adventure";
  					force-gamemode = true;
  					level-type = "flat";
  					generator-settings = ''{"biome":"minecraft:plains","layers":[]}'';
  					generate-structures = false;
  					function-permission-level = 4;
  					simulation-distance = 6;
  					view-distance = 6;
  					max-players = 42;
  					motd = "Kirby Network";
  				};
  				
  				jvmOpts = "-Xms2048M -Xmx2048M -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:+DisableExplicitGC ";

  				symlinks = {
  					mods = pkgs.linkFarmFromDrvs "mods" (builtins.attrValues {
  						FabricAPI = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/UuXf1NbU/fabric-api-0.138.0+1.21.10.jar"; sha512 = "2frq0x18fjr7aimlpn1mr0w16wmxzvc46wrcz4bf8kj7j84qcw91rvzshdpwhb34fj08155a8vb3m13mjp8gpjc6j2z11w2rm7hqgkj"; };
  						ScalableLux = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/Ps1zyz6x/versions/PV9KcrYQ/ScalableLux-0.1.6+fabric.c25518a-all.jar"; sha512 = "3kjl11p15xh80mk61ggz3q32zvc7nzynhh5hf2vpmf3fl8q3qhx10pdqyxqz71829dvirr8k77n95nvgm4b64jgf36xky2wwz0ib5bj"; };
  						C2Me = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/VSNURh3q/versions/uNick7oj/c2me-fabric-mc1.21.10-0.3.5.1.0.jar"; sha512 = "3dw81yqjkl3v6lbj1549y4srfzbxzclyaigmgkgrxm6xs3iw1sdhnwr3673hf6ai69q8p0jywk8c5shf2f71s69lrjzs45r5a3rq1sd"; };
  						FerriteCore = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/uXXizFIs/versions/MGoveONm/ferritecore-8.0.2-fabric.jar"; sha512 = "3nbxsb8kmv95l3zz9xcxicsc4x7a02wplqfkxwb7gm5rgpd5xw9r80mrxpflhzyfbkp5k44smyvikzy3c6ym0zlyn0zdykd27xr0f4c"; };
  						Lithium = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/oGKQMdyZ/lithium-fabric-0.20.0+mc1.21.10.jar"; sha512 = "393wcqdscp9dhpjnklacfvr8rcpzs17q4py6ap7igx8k8126ysmvn7h0inksg1a9ia2rp3bipyyrrnws4in1k1nv728mwznqw7hwp3m"; };
  						XaerosWorldMap = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/NcUtCpym/versions/81Qc21E2/XaerosWorldMap_1.39.17_Fabric_1.21.9.jar"; sha512 = "39d0j50rlprv6mga4p8l3085d35pcsxiygz11sl0kr1qk4s73nypac84idwf9m9njgqgwrpnxxs7047lshsqxdqx6y3nhphd9hps3g6"; };
  						FabricProxyLite = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/8dI2tmqs/versions/nR8AIdvx/FabricProxy-Lite-2.11.0.jar"; sha512 = "c2e1d9279f6f19a561f934b846540b28a033586b4b419b9c1aa27ac43ffc8fad2ce60e212a15406e5fa3907ff5ecbe5af7a5edb183a9ee6737a41e464aec1375"; };
  						VoiceChat = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/BjR2lc4k/voicechat-fabric-1.21.10-2.6.6.jar"; sha512 = "fc0b838a0906ddafeabf9db3b459d4226a2f06458443ee1dee44d937e5896f0d8d3e7c7bbc2a93ea74b4665f37249e7da719bbabf8449c756d2a49116be61197"; };
  					});
  				};

  			};
  			
  			proxy = {
  				enable = true;
  				autoStart = true;
  				restart = "no";
  				package = pkgs.velocityServers.velocity;
  				jvmOpts = "-XX:+UseG1GC -XX:G1HeapRegionSize=4M -XX:+UnlockExperimentalVMOptions -XX:+ParallelRefProcEnabled -XX:+AlwaysPreTouch -XX:MaxInlineLevel=15";
  			};
  		};
  	};

  	samba = {
  		enable = true;
  		openFirewall = true;
  		#securityType = "user";
  		settings = {
  			global = {
  				"server string" = "monolith";
  				"netbios name" = "monolith";
  				"guest account" = "nobody";
  			};
  			"lewis" = {
  				"comment" = "HDD von Lewis";
  				"path" = "/mnt/lewis-hdd";
  				"hosts allow" = "192.168.178.10 192.168.178.60 192.168.178.200 192.168.178.56 192.168.178.164";
  				"browseable" = "yes";
  				"read only" = "no";
  				"guest ok" = "yes";
  				"create mask" = "0644";
  				"directory mask" = "0755";
  				"force user" = "smb-lewis";
  				"force group" = "smb-lewis";
  			};
  		};
  	};

  	samba-wsdd = {
  		enable = true;
  		openFirewall = true;
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
  	
  };
  
  users = {
  	users = {
  		"smb-lewis" = {
  			group = "smb-lewis";
  			isSystemUser = true;
  		};
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
  		"smb-lewis" = {};
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
  			ReadWritePaths = lib.mkForce [ "/mnt/media" ];
  		});
  	};
  	radarr = {
  		serviceConfig = (readWriteOverwrite.serviceConfig // {
  			ReadWritePaths = lib.mkForce [ "/mnt/media" ];
  		});
  	};
  	sonarr = {
  		serviceConfig = (readWriteOverwrite.serviceConfig // {
  			ReadWritePaths = lib.mkForce [ "/mnt/media" ];
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
  		  	OnBootSec = "15m";
  		  	OnUnitActiveSec = "30m";
  		  	AccuracySec = "1m";
  		  	Persistend = false;
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
  		      "minecraft-server-clashcraft.service"
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
