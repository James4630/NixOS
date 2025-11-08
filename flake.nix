{
  description = "NixOS Config Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05-small";
  };

  outputs = { self, nixpkgs }: {
    nixosConfigurations = {
    	monolith = nixpkgs.lib.nixosSystem {
    		system = "x86_64-linux";
    		modules = [
    			./configuration.nix
    			./hardware-configuration.nix
    		];
    	};
    };
  };
}
