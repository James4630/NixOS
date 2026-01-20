{
  description = "NixOS Config Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11-small";
    nixpkgs-2505.url = "github:nixos/nixpkgs/nixos-25.05-small";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
  };

  outputs = { self, nixpkgs, nixpkgs-2505, ...  }@inputs: {
    nixosConfigurations = {
    	monolith = nixpkgs.lib.nixosSystem {
    		specialArgs = {inherit inputs;};
    		system = "x86_64-linux";
    		modules = [
    			./configuration.nix
    			./hardware-configuration.nix
    		];
    	};
    };
  };
}
