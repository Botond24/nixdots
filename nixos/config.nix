{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  networking.hostName = "interloper";
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  imports = [
    ./hardware-configuration.nix
    ./bootloader.nix
    ./language.nix
    ./audio.nix
    ./displayServer.nix
    ./loginManager.nix
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
    device = "/dev/disk/by-uuid/CCA405D1A405BF48";
    fsType = "ntfs3";
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
      "audio"
      "plugdev"
      "docker"
      "networkmanager"
    ];
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

    solaar
    logitech-udev-rules
    ltunify

    starship
    brightnessctl

    nix-index

    wineWow64Packages.staging
    xsettingsd
  ];

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    extraPackages = with pkgs.kdePackages; [
      breeze
    ];
    # localNetworkGameTransfers.openFirewall = true;
    # remotePlay.openFirewall = true;
  };
  services.flatpak.enable = true;

  programs.nix-ld = {
    enable = true;
  };
  programs.gamescope.enable = true;
  programs.gamemode.enable = true;

  programs.ssh = {
    startAgent = true;
    knownHosts = {
      gitlab = {
        hostNames = [ "gitlab.com" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf";
      };
      github = {
        hostNames = [ "github.com" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
