{ config, pkgs, ... }:

{
  home = {
  	username = "james";
  	homeDirectory = "/home/james";
  	#pointerCursor.enable = true;
  	stateVersion = "26.11";
  };
  programs.home-manager.enable = true;  

  imports = [
  	./programs/browsers/firefox/firefox.nix
  	./programs/desktop/fuzzel.nix
  	./programs/desktop/hyprwave.nix
  	./programs/utility/swayimg.nix
  	./programs/cli/bash.nix
  	./programs/cli/alacritty.nix
  	./programs/cli/micro.nix
  	./programs/cli/git.nix
  	./services/bluetooth.nix
  	./services/networking.nix
  	./services/audio.nix
  	./games/prismlauncher.nix
  	./games/hytale.nix
  ];

  home.packages = with pkgs; [
  	fastfetch
  	fortune
  ];

  programs = {
  	tmux = {
  		enable = true;
  		terminal = "tmux-256color";
  		clock24 = true;
  		plugins = with pkgs.tmuxPlugins; [
  			cpu
  			{
  				plugin = resurrect;
  				extraConfig = "set -g @resurrect-capture-pane-contents 'on'";
  			}
  			#{
  			#	plugin = continuum;
  			#	extraConfig = ''
  			#		set -g @continuum-restore 'on'
  			#		set -g @continuum-save-interval '60'
  			#	'';
  			#}
  		];
  	};
  };

}
