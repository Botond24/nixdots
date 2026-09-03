{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.arion.nixosModules.arion
    ./lib.nix
  ];

  custom = rec {
    localDomain = "servereon.localhost";
    domains =  [ "bttn.dev" localDomain ];
    dataPath = "/var/lib/compose";
  };

  virtualisation = {
    docker = {
      enable = true;
      #storageDriver = "btrfs";
      autoPrune = {
        enable = true;
        dates = "weekly";
        allVolumes.enable = true;
      };
    };

    arion = {
      backend = "docker";
      projects = import ./compose { inherit config; inherit pkgs; path = "/etc/nixos/server/compose"; };
    };
  };
}
