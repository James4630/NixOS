{ pkgs, ... }:

{
	environment.systemPackages = with pkgs; [ kdePackages.qtsvg ];
}
