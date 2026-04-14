{
  pkgs,
  ...
}:
{
  boot.loader = {
    systemd-boot.enable = false;
    grub = {
      enable = true;
      useOSProber = true;
      copyKernels = true;
      efiSupport = true;
      fsIdentifier = "uuid";
      default = "saved";
      device = "nodev";
      theme = ../grub-theme;
      extraEntries = ''
        menuentry "UEFI" --class efi $menuentry_id_option 'uefi-firmware' {
                  fwsetup
        }
      '';
    };
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;
}
