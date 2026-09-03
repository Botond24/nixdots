{
  description = "Java Development flake";
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
        javaVersion = 25; # Change this value to update the whole stack


        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };
        stdenv = pkgs.stdenv;
      in
        {
          overlays.default =
            final: prev:
            let
              jdk = prev."jdk${toString javaVersion}";
            in
              {
                inherit jdk;
                maven = prev.maven.override { jdk_headless = jdk; };
                gradle = prev.gradle.override { java = jdk; };
                lombok = prev.lombok.override { inherit jdk; };
              };


          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              gcc
              gradle
              jdk
              maven
              ncurses
              patchelf
              zlib
            ];
            shellHook =
              let
                loadLombok = "-javaagent:${pkgs.lombok}/share/java/lombok.jar";
                prev = "\${JAVA_TOOL_OPTIONS:+ $JAVA_TOOL_OPTIONS}";
              in
              ''
                export JAVA_TOOL_OPTIONS="${loadLombok}${prev}"
              '';
          };

          packages.default = stdenv.mkDerivation  {
            pname = "";
            version = "0.0.0";

            src = ./.;

            buildInputs = with pkgs; [

            ];

            configurePhase = '''';

            buildPhase = '''';

            installPhase = '''';
          };
          formatter = pkgs.nixfmt;
        }
    );
}
