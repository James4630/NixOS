{ config, lib, inputs, agenix, pkgs, ... }:

{
	environment.systemPackages = [
	  inputs.agenix.packages."${pkgs.system}".default
	];
}
