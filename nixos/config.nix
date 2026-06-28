{
  inputs,
  pkgs,
  ...
}:
{


  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  imports = [
    ./hardware-configuration.nix
    ./bootloader.nix
    ./language.nix
    ./audio.nix
    ./displayServer.nix
    ./loginManager.nix
    ./network.nix
    inputs.openrgb-highlighter.nixosModules.x86_64-linux.default
  ];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  zramSwap.enable = true;
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024; # 16 GiB
    }
  ];

  fileSystems."/media/SSD2TB" = {
    device = "/dev/disk/by-label/SSD2TB";
    fsType = "ntfs-3g";
    options = [
      "nofail"
      "x-systemd.automount"
      "rw"
      "uid=1000"
      "gid=100"
      "umask=0022"
    ];
  };

  users.users.button = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "input"
      "tty"
      "audio"
      "plugdev"
      "docker"
      "networkmanager"
    ];
  };
  users.groups = {
    plugdev = { };
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    lm_sensors
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    gnupg
    btop
    lsof
    killall
    pciutils
    ntfs3g

    solaar
    logitech-udev-rules
    ltunify

    starship
    brightnessctl

    nix-index
    comma

    wineWow64Packages.staging
    xsettingsd
    wayvr
  ];

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    extraPackages = with pkgs.kdePackages; [
      breeze
    ];
    localNetworkGameTransfers.openFirewall = true;
    remotePlay.openFirewall = true;
  };
  services.wivrn = {
    enable = true;
    openFirewall = true;
    package = (pkgs.wivrn.override { cudaSupport = true; });
    steam.importOXRRuntimes = true;
    highPriority = true;
  };

  programs.nix-ld = {
    enable = true;
  };
  programs.gamescope.enable = true;
  programs.gamemode.enable = true;

  services.flatpak.enable = true;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/button/.config/nixos"; # sets NH_OS_FLAKE variable for you
  };

  programs.ssh = {
    startAgent = true;
    knownHosts = {
      gitlab = {
        hostNames = [ "gitlab.com" ];
        publicKey = builtins.readFile "${inputs.ssh}/gitlab.pub";
      };
      github = {
        hostNames = [ "github.com" ];
        publicKey = builtins.readFile "${inputs.ssh}/github.pub";
      };
    };
    extraConfig = ''
      Host gitlab.com
        IdentityFile ${inputs.ssh}/gitlab

      Host github.com
        IdentityFile ${inputs.ssh}/github
    '';
  };

  hardware.logitech.wireless.enable = true;
  hardware.bluetooth.enable = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  services.hardware.openrgb.enable = true;
  services.openrgb-highlighter = {
    enable = true;
    user = "button";
  };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "button";
    dataDir = "/home/button/Sync";
    databaseDir = "/home/button/.local/state/syncthing"; # Default folder for new synced folders
    configDir = "/home/button/.config/syncthing"; # Folder for Syncthing's settings and keys
    guiPasswordFile = "${inputs.ssh}/synchting/passwordFile";
    settings = {
      devices = {
        phone = {
          id = "5WQBAPP-VOSWWUC-6KRBFYP-Y57UYWO-BTNDCLF-CVAXY4L-65HLDZX-Y7D32AX";
        };
      };
      folders = {
        keepass = {
          id = "sx1q2-w8q15";
          label = "KeePass";
          devices = [ "phone" ];
          path = "/home/button/keepass";
        };
      };
      options.urAccepted = -1;
    };
  };


  # Numworks
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="0483", ATTR{idProduct}=="a291", MODE="0666", GROUP="plugdev"
    SUBSYSTEM=="usb", ATTR{idVendor}=="0483", ATTR{idProduct}=="df11", MODE="0666", GROUP="plugdev"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="3000", MODE="0666"
  '';

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
