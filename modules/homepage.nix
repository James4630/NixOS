{
	services.homepage-dashboard = {
		#https://gethomepage.dev/configs/
		#https://search.nixos.org/options?channel=25.05&query=services.homepage-dashboard
		enable = true;
		allowedHosts = "elliotkirby.de,192.168.178.42:8082,localhost:8082,127.0.0.1:8082";
		
		settings = {
			title = "Home";
			description = "Homepage";
			theme = "dark";
			color = "slate";
			headerStyle = "boxed";
			language = "en-DE";
			background = {
				image = "https://images.pexels.com/photos/691668/pexels-photo-691668.jpeg";
			};
			cardBlur = "xl";
			target = "_self";
			quicklaunch = {
				searchDescriptions = true;
				showSearchSuggestions = true;
				provider = "duckduckgo";
				mobileButtonPosition = "bottom-left";
			};
			hideVersion = true;
			statusStyle = "dot";
			layout = {
				Media_c = {
					style = "row";
					columns = 2;
					Media = {
						style = "row";
						columns = 2;
					};
				};
				Router = {};
				Services = {};
				arr = {};
				Web = {
					iconsOnly = true;
					style = "row";
				};
			};
		};

		bookmarks = [
			{
				Web = [
					{
						Mail = [
							{
								icon = "sh-proton-mail";
								href = "https://mail.proton.me/u/1/t1kvLWJWJLO1nXa-QnuZcJvSSUEOI3hawl4tsqGMRJq7nvmbp0ESnJlwF4yeagTnCyxKF2_-wMDyGRvqnIE6CQ==";
								description = "Protonmail";
							}
						];
					}
				];
			}
		];

		widgets = [
			{
				resources = {
					label = "System";
					cpu = true;
					cputemp = true;
					memory = true;
					uptime = true;
					network = true;
					units = "metric";
					expanded = true;
				};
			}
			{
				logo = {};
			}
			{
				datetime = {
					text_size = "x1";
					format = {
						timeStyle = "short";
						hourCycle = "h23";
					};
				};
			}
			{
				resources = {
					label = "Storage";
					disk = [ "/" "/mnt/storage"];
					expanded = true;
				};
			}
			#{
			#	search = {
			#		provider = "duckduckgo";
			#		#url = "https://www.startpage.com/sp/search?query=";
			#		focus = false;
			#		showSearchSuggestions = true;
			#		target = "_self";
			#	};
			#}
		];

		services = [
			{
				Media_c = [
					{
						Calendar = [
							{
								Calendar = {
									widget = {
										type = "calendar";
										showTime = true;
										integrations = {
											type = "lidarr";
											service_group = "arr";
											service_name = "Lidarr";
										};
									};
								};
							}
						];
					}
					{
						Media = [
							{
								Immich = {
									description = "Photos Cloud";
									icon = "immich";
									href = "https://immich.elliotkirby.de/";
									#ping = "immich.elliotkirby.de";
								};
							}
							{
								Seafile = {
									description = "Cloud Storage";
									icon = "seafile";
									href = "https://seafile.elliotkirby.de/";
									#ping = "seafile.elliotkirby.de";
								};
							}
							{
								Jellyfin = {
									description = "Movies and Shows";
									icon = "jellyfin";
									href = "https://jellyfin.elliotkirby.de";
									widget = {
										type = "jellyfin";
										url = "https://jellyfin.elliotkirby.de";
										key = "ac3b765a11614a05bdabeac94810606e";
										enableBlocks = true;
										fields = [ "movies" "series" "episodes" ];
										enableUser = true;
										showEpisodeNumber = true;
									};
								};
							}
							{
								Navidrome = {
									description = "Music/Subsonic Server";
									icon = "navidrome";
									href = "https://navidrome.elliotkirby.de";
									widget = {
										type = "navidrome";
										url = "https://navidrome.elliotkirby.de";
										user = "homepage";
										token = "d06347496e9a68e70b1e044dfa60b812";
										salt = "R1abG9";
									};
								};
							}
						];
					}
				];
			}
			{
				Router = [
					{
						FRITZBox = {
							description = "FRITZ!Box interface";
							href = "http://fritz.box";
							icon = "fritzbox";
							widget = {
								type = "fritzbox";
								url = "http://192.168.178.1";
								fields = ["uptime" "down" "maxDown" "received"];
							};
						};
					}
				];
			}
			{
				Services = [
					{
						Vaultwarden = {
							description = "Bitwarden Server/Webvault";
							icon = "vaultwarden";
							href = "https://bitwarden.elliotkirby.de/";
							#ping = "bitwarden.elliotkirby.de";
						};
					}
					{
						MicroBin = {
							description = "simple file sharing";
							icon = "microbin";
							href = "https://bin.elliotkirby.de";
						};
					}
					{
						slskd = {
							description = "slsk server/client for automated downloads";
							icon = "slskd";
							href = "https://slskd.elliotkirby.de";
							widget = {
								type = "slskd";
								url = "https://slskd.elliotkirby.de";
								key = "WVxrJQ349lG9tLVrk7/OTILKRGWCE+0ldQrRu56KCdVUVhSHEGmcjd1luJqIXY5l";
							};
						};
					}
				];
			}
			{
				arr = [
					{
						Lidarr = {
							description = "automated music manager";
							icon = "lidarr";
							href = "https://lidarr.elliotkirby.de";
							widget = {
								type = "lidarr";
								url = "https://lidarr.elliotkirby.de";
								key = "0aef1fe725b24d9abe5c792beaebdd73";
								fields = [ "wanted" "artists" ];
							};
						};
					}
				];
			}
		];

		customCSS = "#information-widgets .dark\\:text-theme-200:is(.dark *) {color:rgb(64,64,64)} .services-group h2 {color: grey;}";
		
	};
}
