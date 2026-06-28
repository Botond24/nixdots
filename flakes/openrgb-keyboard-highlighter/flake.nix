{
  description = "OpenRGB Keypress Reactive Ligthing";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "systems";
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        stdenv = pkgs.stdenv;
        python = (pkgs.python3.withPackages (ps: with ps; [
          keyboard
          openrgb-python
          watchdog
          pyyaml
          i3ipc
        ]));
      in
      rec {
        packages.default = pkgs.python3Packages.callPackage ./default.nix {};

        nixosModules.default = { config, lib, pkgs, ... }: import ./module.nix { inherit config lib pkgs; package = packages.default;};
      }
    );
}
