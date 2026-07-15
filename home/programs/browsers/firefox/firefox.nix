{ pkgs, config, ... }:

{
	programs.firefox = {
		enable = true;

		profiles = {
			main = {
				id = 0;
				isDefault = true;
				path = "1snrdig0.default";

				search = {
					force = true;
					
					privateDefault = "ddg";

					engines = {
					  "Nix Packages" = {
					    urls = [
					      {
					        template = "https://search.nixos.org/packages";
					        params = [
					          { name = "channel"; value = "unstable"; }
					          { name = "query";   value = "{searchTerms}"; }
					        ];
					      }
					    ];
					    icon           = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
					    definedAliases = [ "@np" ];
					  };

					  "Nix Options" = {
					    urls = [
					      {
					        template = "https://search.nixos.org/options";
					        params = [
					          { name = "channel"; value = "unstable"; }
					          { name = "query";   value = "{searchTerms}"; }
					        ];
					      }
					    ];
					    icon           = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
					    definedAliases = [ "@no" ];
					  };

					  "NixOS Wiki" = {
					    urls = [
					      {
					        template = "https://wiki.nixos.org/w/index.php";
					        params = [
					          { name = "search"; value = "{searchTerms}"; }
					        ];
					      }
					    ];
					    icon           = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
					    definedAliases = [ "@nw" ];
					  };
					};
					
				};

				settings = {
					"toolkit.legacyUserProfileCustomizations.stylesheets" = true;
					"widget.wayland.opaque-region.enabled" = false;
					"widget.transparent-windows" = true;
				};
			};
		};

		policies = {
			DisableFirefoxStudies = true;
			DisableFirefoxAccounts = true;
			DisableProfileImport = true;
			DisableProfileRefresh = true;
			DisableRemoteImprovements = true;

			DontCheckDefaultBrowser = true;
			OfferToSaveLogins = false;

			BrowserDataBackup = {
				AllowBackup = false;
				AllowRestore = false;
			};

			Homepage = {
				URL = "https://elliotkirby.de";
				StartPage = "previous-session";
			};

			FirefoxHome = {
				Search = true;
				TopSites = false;
				SponsoredTopSites = false;
				Highlights = false;
			};

			AIControls = {
				Translations = { Value = "available"; };
				LinkPreviewKeyPoints = { Value = "available"; };
				PDFAltText = { Value = "blocked"; };
				SmartTabGroups = { Value = "blocked"; };
				SmartWindow = { Value = "blocked"; };
				SidebarChatbot = { Value = "blocked"; };
			};

			AutofillAddressEnabled = true;
			AutofillCreditCardEnabled =  false;

			Cookies = {
				Behavior = "reject-tracker";
			};

			DisplayBookmarksToolbar = "newtab";

			DNSOverHTTPS = {
				Enabled = true;
				ProviderURL = "https://mozilla.cloudflare-dns.com/dns-query";
				Fallback = true;
			};

			EnableTrackingProtection = {
				Value = true;
				Cryptomining = true;
				Fingerprintingg = true;
				EmailTrackingg = true;
				SuspectedFingerprintingg = true;
			};

			HardwareAcceleration = true;

			HttpAllowlist = [
				"http://fritz.box"
			];

			OverrideFirstRunPage = "";
			OverridePostUpdatePage = "";

			PasswordManagerEnabled = false;

			ShowHomeButton = true;

			SkipTermsOfUse = true;

			UserMessaging = {
				ExtensionRecommendations = false;
				FeatureRecommendations = false;
				SkipOnboarding = true;
				MoreFromMozilla = false;
			};

			Preferences = {
				"browser.ctrlTab.sortByRecentlyUsed" = { Value = true; };
			};
			
			#Extensions
			ExtensionSettings = let
			  moz = short: "https://addons.mozilla.org/firefox/downloads/latest/${short}/latest.xpi";
			in {
			  "*".installation_mode = "blocked";

			  "uBlock0@raymondhill.net" = {
			    install_url       = moz "ublock-origin";
			    installation_mode = "force_installed";
			    updates_disabled  = true;
			  };
			  
			  "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
			    install_url       = moz "bitwarden-password-manager";
			    installation_mode = "force_installed";
			    updates_disabled  = true;
			  };
			  
			  "toolbar@gmx.net" = {
			    install_url       = moz "gmx-mailcheck";
			    installation_mode = "force_installed";
			    updates_disabled  = true;
			  };
			  
			};
		};
	};

	imports = [ ./css.nix ];
}
