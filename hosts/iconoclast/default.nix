{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./power.nix
      ../../modules/bootloader/systemd-boot.nix
      ../../modules/common/locale.nix
      ../../modules/common/nix.nix
      ../../modules/packages/base.nix
      ../../modules/packages/wl-clipboard.nix
      ../../modules/packages/audio.nix
      ../../modules/packages/xwayland-satellite.nix
      ../../modules/packages/hyprwave/hyprwave.nix
      ../../modules/packages/kde/all.nix
      ../../modules/packages/cli/wev.nix
      ../../modules/packages/cli/brightnessctl.nix
      ../../modules/packages/cli/git.nix
      ../../modules/packages/cli/agenix.nix
      ../../modules/packages/cli/wireguard-tools.nix
      ../../modules/services/base/all.nix
      ../../modules/services/power-management.nix
      ../../modules/services/tuigreet.nix
      ../../modules/services/wireguard.nix
      ../../modules/desktop/niri.nix
      ../../modules/fonts/jetbrains-mono.nix
      ../../modules/packages/apps/iloader.nix
      ../../modules/packages/apps/baobab.nix
      ../../modules/packages/apps/feishin.nix
      ../../modules/packages/apps/steam.nix
      ../../users/users.nix
    ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  networking.hostName = "iconoclast";
  system.stateVersion = "26.11";

  environment.systemPackages = with pkgs; [
    acpi
  ];
}
