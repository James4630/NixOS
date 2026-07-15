{ inputs, config, pkgs, ... }:

{

	imports = [
		../services/mako.nix
		../services/clipse.nix
		../services/hypridle.nix
		../programs/desktop/hyprlock.nix
		../programs/desktop/waybar.nix
		../programs/desktop/wlogout.nix
		../theming/awww.nix
		../theming/catppuccin.nix
	];
	
	programs.niri = {
		settings = {
			prefer-no-csd = true;
			outputs."eDP-1".scale = 1.0;

			blur = {
				enable = true;
				
				passes = 4;
				offset = 2.0;
				noise = 0.02;
			};

			window-rules = [
				{
					matches = [ { app-id = "org.kde.gwenview"; } ];
					open-floating = true;
				}
				{
					matches = [ { app-id = "steam"; } ];
					open-fullscreen = true;
				}
				{
					matches = [ { app-id = "^clipse$"; } ];
					open-floating = true;
					default-column-width.fixed = 800;
					default-window-height.fixed = 600;
				}
				{
					matches = [ { app-id = "org.pulseaudio.pavucontrol"; } ];
					open-floating = true;
					default-column-width.fixed = 800;
					default-window-height.fixed = 600;
				}
				{
					matches = [ { app-id = ".blueman-manager-wrapped"; } ];
					open-floating = true;
					default-column-width.fixed = 800;
					default-window-height.fixed = 600;
				}
				{
					matches = [ { app-id = "org.gnome.baobab"; } ];
					open-floating = true;
					default-column-width.fixed = 800;
					default-window-height.fixed = 600;
				}
				{
					matches = [ { app-id = "firefox"; } ];
					background-effect = {
						blur = true;
						xray = true;
						saturation = 0.8;
					};
				}
			];

			layer-rules = [
			  {
			    matches = [ { namespace = "^awww-daemon$"; } ];
			    place-within-backdrop = true;
			  }
			  {
			    matches = [ { namespace = "^waybar$"; } ];
			    background-effect = {
			    	blur = true;
			    	xray = true;
			    	saturation = 1;
			    };
			  }
			];

			layout = {
				background-color = "transparent";
				gaps = 10;
				focus-ring.enable = false;
			};

			spawn-at-startup = [
				{
					command = [ "hyprwave" ];
				}
			];
			
			binds = {
				# System
				"Mod+Shift+Slash".action.show-hotkey-overlay = {};
				"Mod+Shift+E".action.quit = {};
				"Ctrl+Alt+Delete".action.spawn = "wlogout";
				"XF86Explorer".action.toggle-overview = {};

				# Programs
				"Mod+T".action.spawn = "alacritty";
				"Mod+D".action.spawn = "fuzzel";
				"XF86Search".action.spawn = "fuzzel";
				"Mod+Alt+L".action.spawn = "hyprlock";
				"Mod+E".action.spawn = "dolphin";
				"Mod+V".action.spawn = [ "alacritty" "-o" "window.opacity=1.0" "--class" "clipse" "-e" "clipse" ];
				"XF86Tools".action.spawn = [ "alacritty" "--working-directory" "../../" ];

				#Hyprwave
				"Mod+Shift+M".action.spawn = [ "hyprwave-toggle" "visibility" ];
				"Mod+Alt+M".action.spawn = [ "hyprwave-toggle" "expand" ];
				"Mod+P".action.spawn = [ "hyprwave-toggle" "play" ];
				"Mod+Period".action.spawn = [ "hyprwave-toggle" "next" ];
				"Mod+Comma".action.spawn = [ "hyprwave-toggle" "prev" ];
				"Mod+Shift+T".action.spawn = [ "hyprwave-toggle" "set-theme" "nebula" ];

				#Brightness
				"XF86MonBrightnessUp" = {
					allow-when-locked = true;
					action.spawn = [ "brightnessctl" "--class=backlight" "set" "+5%" ];
				};
				"XF86MonBrightnessDown" = {
					allow-when-locked = true;
					action.spawn = [ "brightnessctl" "--class=backlight" "set" "5%-" ];
				};

				#WiFi
				"XF86WLAN".action.spawn = [ pkgs.runtimeShell "-c" ''nmcli radio wifi $([ "$(nmcli radio wifi)" = enabled ] && echo off || echo on)'' ];

				#Volume
				"XF86AudioRaiseVolume" = {
					allow-when-locked = true;
					action.spawn = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+" "-l" "1.0" ];
				};
				"XF86AudioLowerVolume" = {
					allow-when-locked = true;
					action.spawn = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-" ];
				};
				"XF86AudioMute" = {
					allow-when-locked = true;
					action.spawn = [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle" ];
				};
				"XF86AudioMicMute" = {
					allow-when-locked = true;
					action.spawn = [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle" ];
				};

				#Media
				"XF86AudioPlay" = {
				  allow-when-locked = true;
				  action.spawn = [ "playerctl" "play-pause" ];
				};

				"XF86AudioPause" = {
				  allow-when-locked = true;
				  action.spawn = [ "playerctl" "play-pause" ];
				};

				"XF86AudioStop" = {
				  allow-when-locked = true;
				  action.spawn = [ "playerctl" "stop" ];
				};

				"XF86AudioNext" = {
				  allow-when-locked = true;
				  action.spawn = [ "playerctl" "next" ];
				};

				"XF86AudioPrev" = {
				  allow-when-locked = true;
				  action.spawn = [ "playerctl" "previous" ];
				};
				
				# Windows
				"Mod+Q".action.close-window = {};

				# Focus columns/windows
				#"Mod+H".action.focus-column-left = {};
				"Mod+Left".action.focus-column-left = {};

				#"Mod+L".action.focus-column-right = {};
				"Mod+Right".action.focus-column-right = {};

				#"Mod+J".action.focus-window-down = {};
				"Mod+Down".action.focus-window-down = {};

				#"Mod+K".action.focus-window-up = {};
				"Mod+Up".action.focus-window-up = {};

				# Move columns/windows
				#"Mod+Ctrl+H".action.move-column-left = {};
			    "Mod+Ctrl+Left".action.move-column-left = {};
			
			    #"Mod+Ctrl+L".action.move-column-right = {};
			    "Mod+Ctrl+Right".action.move-column-right = {};
			
			    #"Mod+Ctrl+J".action.move-window-down = {};
			    "Mod+Ctrl+Down".action.move-window-down = {};
			
			    #"Mod+Ctrl+K".action.move-window-up = {};
			    "Mod+Ctrl+Up".action.move-window-up = {};

			    # Focus monitor
			    #"Mod+Shift+H".action.focus-monitor-left = {};
			    "Mod+Shift+Left".action.focus-monitor-left = {};

			    #"Mod+Shift+L".action.focus-monitor-right = {};
			    "Mod+Shift+Right".action.focus-monitor-right = {};

			    #"Mod+Shift+J".action.focus-monitor-down = {};
			    "Mod+Shift+Down".action.focus-monitor-down = {};

			    #"Mod+Shift+K".action.focus-monitor-up = {};
			    "Mod+Shift+Up".action.focus-monitor-up = {};

			    # Move focused column to monitor
			    #"Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = {};
			    "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = {};

			    #"Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = {};
			    "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = {};

			    #"Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = {};
			    "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down = {};

			    #"Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = {};
			    "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up = {};

			    # Workspaces
			    #"Mod+U".action.focus-workspace-down = {};
			    "Mod+Page_Down".action.focus-workspace-down = {};

			    #"Mod+I".action.focus-workspace-up = {};
			    "Mod+Page_Up".action.focus-workspace-up = {};

			    #"Mod+Ctrl+U".action.move-column-to-workspace-down = {};
			    "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = {};

			    #"Mod+Ctrl+I".action.move-column-to-workspace-up = {};
			    "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = {};

			    #"Mod+Shift+U".action.move-workspace-down = {};
			    "Mod+Shift+Page_Down".action.move-workspace-down = {};

			    #"Mod+Shift+I".action.move-workspace-up = {};
			    "Mod+Shift+Page_Up".action.move-workspace-up = {};

			    # Consume / Expel
			    "Mod+BracketLeft".action.consume-or-expel-window-left = {};
			    "Mod+BracketRight".action.consume-or-expel-window-right = {};

			    # Column width presets
			    "Mod+R".action.switch-preset-column-width = {};
			    "Mod+Shift+R".action.switch-preset-column-width-back = {};

			    # Maximize / center
			    "Mod+M".action.maximize-window-to-edges = {};
			    "Mod+C".action.center-column = {};

			    # Column width
			    "Mod+Minus".action.set-column-width = "-10%";
			    "Mod+Equal".action.set-column-width = "+10%";

			    # Window height
			    "Mod+Shift+Minus".action.set-window-height = "-10%";
			    "Mod+Shift+Equal".action.set-window-height = "+10%";
			    "Mod+Ctrl+R".action.reset-window-height = {};

			    # Fullscreen
			    "Mod+Shift+F".action.fullscreen-window = {};

			    # Floating / tiling
			    "Mod+Ctrl+V".action.toggle-window-floating = {};
			    "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = {};

			    # Screenshots
			    "Print".action.screenshot = {};
			    "Alt+Print".action.screenshot-window = {};
			    "Ctrl+Print".action.screenshot-screen = {};
			};
		};
	};
}
