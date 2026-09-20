{
    pkgs,
    ...
}: {
    fileSystems = {
        "/".options = [ "compress=zstd" ];
        "/home".options = [ "compress=zstd" ];
        "/nix".options = [ "compress=zstd" "noatime" ];
        "/swap".options = [ "noatime" ];
        "/boot" = {
          device = "/dev/disk/by-uuid/4019-488C";
          fsType = "vfat";
        }
    };

    services.btrfs.autoScrub = {
        enable = true;
        interval = "weekly";
        fileSystems = [ "/" ];
    };

    services.beesd.filesystems = {
        root = {
            spec = "LABEL=INTERLOPER";
            hashTableSizeMB = 2048;
            verbosity = "crit";
            extraOptions = [ "--loadavg-target" "5.0" ];
        };
    };
}
