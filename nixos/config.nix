{
  inputs,
  pkgs,
  config,
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
    ./nix-index.nix
    inputs.openrgb-highlighter.nixosModules.x86_64-linux.default
#    ../server/config.nix
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

    deluge

    solaar
    logitech-udev-rules
    ltunify

    starship
    brightnessctl

    wineWow64Packages.staging
    xsettingsd
    wayvr
  ];

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    extraPackages = with pkgs.kdePackages; [
      breeze
      pkgs.wavpack
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
        publicKeyFile = "${inputs.ssh}/gitlab.pub";
      };
      github = {
        hostNames = [ "github.com" ];
        publicKeyFile = "${inputs.ssh}/github.pub";
      };
    };
    extraConfig = ''
      Host gitlab.com
        IdentityFile ${inputs.ssh}/gitlab

      Host github.com
        IdentityFile ${inputs.ssh}/github
    '';
    knownHostsFiles = [
      (pkgs.writeText "github.keys" ''
github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=
github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=
github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl

      '')
      (pkgs.writeText "gitlab.keys" ''
gitlab.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCsj2bNKTBSpIYDEGk9KxsGh3mySTRgMtXL583qmBpzeQ+jqCMRgBqB98u3z++J1sKlXHWfM9dyhSevkMwSbhoR8XIq/U0tCNyokEi/ueaBMCvbcTHhO7FcwzY92WK4Yt0aGROY5qX2UKSeOvuP4D6TPqKF1onrSzH9bx9XUf2lEdWT/ia1NEKjunUqu1xOB/StKDHMoX4/OKyIzuS0q/T1zOATthvasJFoPrAjkohTyaDUz2LN5JoH839hViyEG82yB+MjcFV5MU3N1l1QL3cVUCh93xSaua1N85qivl+siMkPGbO5xR/En4iEY6K2XPASUEMaieWVNTRCtJ4S8H+9
gitlab.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFSMqzJeV9rUzU4kWitGjeR4PWSa29SPqJ1fVkhtj3Hw9xjLVXVYrU9QlYWrOLXBpQ6KWjbjTDTdDkoohFzgbEY=
gitlab.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf
      '')
    ];
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


  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  services.syncthing = rec {
    enable = true;
    openDefaultPorts = true;
    user = "button";
    dataDir = "${config.users.users."${user}".home}/Sync";
    databaseDir = "${config.users.users."${user}".home}/.local/state/syncthing"; # Default folder for new synced folders
    configDir = "${config.users.users."${user}".home}/.config/syncthing"; # Folder for Syncthing's settings and keys
    guiPasswordFile = "${inputs.ssh}/synchting/passwordFile";
    settings = {
      devices = {
        phone = {
          id = "ORMM2CL-TLWLQCV-4LCZ5CV-GHAJW55-TNDDUSM-C6KDBM6-YLE7ALF-EUVS3QU";
        };
      };
      folders = {
        keepass = {
          id = "sx1q2-w8q15";
          label = "KeePass";
          devices = [ "phone" ];
          path = "${config.users.users."${user}".home}/keepass";
        };
      };
      options.urAccepted = -1;
    };
  };
  # Numworks
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="0483", ATTR{idProduct}=="a291", MODE="0666", GROUP="plugdev"
    SUBSYSTEM=="usb", ATTR{idVendor}=="0483", ATTR{idProduct}=="df11", MODE="0666", GROUP="plugdev"
  '';

  virtualisation.docker = {
    enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
