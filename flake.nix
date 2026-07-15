{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
    	url = "github:nix-community/home-manager";
    	inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
    	#url = "github:sodiboo/niri-flake";
    	url = "github:myume/niri-flake/blur";
    	inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprwave-src = {
    	url = "github:shantanubaddar/hyprwave/v1.0";
    	flake = false;
    };
    agenix = {
    	url = "github:ryantm/agenix";
    	inputs.darwin.follows = "";
    };
    nix-minecraft = {
    	url = "github:Infinidoge/nix-minecraft";
    	inputs.nixpkgs.follows = "nixpkgs";
    };
    awww.url = "git+https://codeberg.org/LGFae/awww";
    catppuccin.url = "github:catppuccin/nix";
    iloader.url = "github:nab138/iloader";
    hytale-launcher.url = "github:JPyke3/hytale-launcher-nix";
  };
  
  outputs = inputs@{ self, nixpkgs, home-manager, catppuccin, agenix, ... }: {
    nixosConfigurations = {
    
    	iconoclast = nixpkgs.lib.nixosSystem {
    		system = "x86_64-linux";
    		specialArgs = { inherit inputs; };
    		modules = [
    		
    			./hosts/iconoclast/default.nix

    			catppuccin.nixosModules.catppuccin

    			agenix.nixosModules.default
    			
    			home-manager.nixosModules.home-manager
    			{
    				home-manager.useGlobalPkgs = true;
    				home-manager.useUserPackages = true;
    				home-manager.extraSpecialArgs = { inherit inputs; };
    				home-manager.users.james = {
    					imports = [
    						./home/james.nix
    						./home/desktop/niri.nix
    						catppuccin.homeModules.catppuccin
    						agenix.homeManagerModules.default
    					];
    				};
    			}
    			
    		];
    	};

    	lateralus = nixpkgs.lib.nixosSystem {
    		specialArgs = {inherit inputs;};
    		system = "x86_64-linux";
    		modules = [
    			./server/configuration.nix
    		];
    	};
    	
    };
  };
}
