{
  description = "C/C++ Development flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "systems";
  };

  outputs =
    { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        stdenv = pkgs.stdenv;
      in
        {
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
                clang
                gcc
                gdb
                cmake
                gnumake
                ctags
                findutils
                gnutar
            ];

          };
          packages.default = stdenv.mkDerivation  {
            pname = "";
            version = "0.0.0";

            src = ./.;

            buildInputs = with pkgs; [

            ];

            configurePhase = ''

            '';

            buildPhase = ''

            '';

            installPhase = ''

            '';
          };
          formatter = pkgs.nixfmt;
        }
    );
}
