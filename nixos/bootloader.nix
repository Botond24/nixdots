{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  boot.loader = {
    systemd-boot.enable = false;
    grub = {
      enable = true;
      useOSProber = true;
      copyKernels = true;
      efiSupport = true;
      fsIdentifier = "uuid";
      default =  "saved";
      device = "nodev";
      theme = ../grub-theme;
    };
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;
}
