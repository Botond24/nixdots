{

}: let
  # make a disko.devices.disk attrset that empty-format the given disks before anything else
  mkEmptyDisks = { before ? "", devices }:
    builtins.listToAttrs (builtins.genList (i:
      let dev = builtins.elemAt devices i;
      in {
        # disks are formatted alphabetically, these dummys must be formatted first, so we prefix with zeros
        name = "#before:${before}:${toString i}";
        value = {
          type = "disk";
          device = dev;
          content = {
            type = "gpt";
            partitions = { };
          };
        };
      }) (builtins.length devices));
  # make a disko.devices.disk attrset forming a btrfs raid from a list of devices
  # The *first* device in this list will be mounted (which will auto-mount the others)
  mkBtrfsRAID = { name, devices, raid ? "raid1", content ? { } }:
    {
      "${name}" = {
        type = "disk";
        # The first device in the list is used, but it could be any of those
        device = builtins.head devices;
        content = content // {
          type = "btrfs";
          extraArgs = (content.extraArgs or [ ])
            ++ [ /*"-f"*/ "-d ${raid}" ] ++
            # disko has no builtin concept of collections of btrfs disks,
            # so we sneak all the other parts of the RAID into the creation of the "first" one
            # Below, all of these other disks are first formatted empty
            # to ensure disko knows about them and asks the user for confirmation upon formatting
            builtins.tail devices;
        };
      };
    }
    # This will first empty-format all the other parts of the RAID
    # This ensures disko will ask for confirmation to empty those out
    // mkEmptyDisks {
      before = name;
      devices = builtins.tail devices;
    };
in {
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/nix" ];
  };

  services.beesd.filesystems = {
    root = {
      spec = "LABEL=root";
      hashTableSizeMB = 2048;
      verbosity = "crit";
      extraOptions = [ "--loadavg-target" "5.0" ];
    };
  };

  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-diskseq/1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              start = "1M";
              end = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                subvolumes = {
                  "/root" = {
                    mountOptions = [
                      "compress=zstd"
                    ];
                    mountpoint = "/";
                  };
                  "/nix" = {
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                    mountpoint = "/nix";
                  };
                  "/home" = {
                    mountOptions = [ "compress=zstd" ];
                    mountpoint = "/home";
                  };
                  "/swap" = {
                    mountpoint = "/.swapvol";
                    swap = {
                      swapfile.size = "8G";
                    };
                  };
                };
              };
              mountpoint = "/partition-root";
              swap = {
                swapfile = {
                  size = "20M";
                };
                swapfile1 = {
                  size = "20M";
                };
              };
            };
          };
        };
      };
      backed_up_d1 = {
        type = "disk";
        device = "/dev/disk/by-diskseq/3";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
      backed_up_d2 = {
        type = "disk";
        device = "/dev/disk/by-diskseq/4";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
    } // mkBtrfsRAID {
      name = "Large";
      devices = [
        "/dev/disk/by-diskseq/2"
      ];
      content = {
        mountpoint = "/large-root";
        subvolumes = {
          jelly = {
            mountpoint = "/mnt/jelly";
          };
        };
      };
    };
    zpool = {
      zroot = {
        type = "zpool";
        mode = "mirror";
        options.cachefile = "none";
        rootFsOptions = {
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";
        };
        mountpoint = "/zroot-root";
        datasets = {
          images = {
            type = "zfs_fs";
            mountpoint = "/mnt/images";
          };
        };
      };
    };
  };
}
