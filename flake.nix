{
  description = "Button's NixOS config + server config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:Botond24/stylix/step-1-tinty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ssh = {
      url = "path:/etc/nixos/.ssh";
      flake = false;
    };

    arion = {
      url = "github:hercules-ci/arion";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko-zfs = {
      url = "github:numtide/disko-zfs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.disko.follows = "disko";
    };

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/?ref=latest";
    };
    nix-index = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord = {
      url = "github:FlameFlag/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:Botond24/plasma-manager";
      inputs.nixpkgs.follows ="nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    openrgb-highlighter = {
      url = "github:Botond24/openrgb-keyboard-highlighter";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dev-templates = {
      url = "github:the-nix-way/dev-templates";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-jetbrains-plugins = {
      url = "github:nix-community/nix-jetbrains-plugins";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    {
      nixosConfigurations.interloper = nixpkgs.lib.nixosSystem {
        # system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          inputs.nur.modules.nixos.default
          ./stylix
          ./nixos/config.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            #home-manager.verbose = true;
            home-manager.users.button = import ./home/home.nix;
          }
          ./asus/fa608wv
        ];
      };

      nixosConfigurations.servereon = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./nixos/hardware-configuration.nix
          ./server/config.nix
          inputs.disko.nixosModules.default
          inputs.disko-zfs.nixosModules.default
        ];
      };

      templates = let
        generateTemplates = inpath: overwrites: let
          dir = builtins.readDir inpath;
          folders = builtins.attrNames dir;
        in (builtins.listToAttrs (map (x: { name = "${x}"; value = { path = inpath + "/${x}"; description = "Template for ${x} development.";};}) folders)) // overwrites;
      in generateTemplates ./templates {
        cpp = self.templates.c // { description = "Template for c++ development (local).";};
      };
    };
}
