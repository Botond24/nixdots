{
  description = "Golang Development flake";
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
        goVersion = 25; # Change this to update the whole stack

        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };
        stdenv = pkgs.stdenv;
      in
        {
          overlays.default = final: prev: {
            go = final."go_1_${toString goVersion}";
          };

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              go
              gotool
              golangci-lint
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
