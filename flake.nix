{
  description = "NixOS Config Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
  };

  outputs = { self, nixpkgs, ...  }@inputs: {
    nixosConfigurations = {
    	lateralus = nixpkgs.lib.nixosSystem {
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
