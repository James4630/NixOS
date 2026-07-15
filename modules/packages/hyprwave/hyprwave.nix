{ inputs, pkgs, ... }:

let
  hyprwave = pkgs.callPackage ./default.nix {
    src = inputs.hyprwave-src;
  };
in
{
  environment.systemPackages = [
    hyprwave
  ];

  fonts.packages = [
    hyprwave
  ];
}
