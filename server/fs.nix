{

}: {

  imports = [
    ./disko.nix
    ./kernel.nix
  ];

  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/" ];
  };

  services.beesd.filesystems = {
    root = {
      spec = "LABEL=root";
      hashTableSizeMB = 2048;
      verbosity = "crit";
      extraOptions = [ "--loadavg-target" "5.0" ];
    };
  };

  boot.zfs.enable = true;
  services.zfs = {
    autoScrub = {
      enable = true;
      interval = "weekly";
    };
    trim = {
      enable = true;
      interval = "monthly";
    };
  };
}
