{
  description = "Python Development flake";
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
          #overlays = [ self.overlays.${system}.default ];
        };
        stdenv = pkgs.stdenv;
        lib = pkgs.lib;

        /*
          Change this value ({major}.{min}) to
          update the Python virtual-environment
          version. When you do this, make sure
          to delete the `.venv` directory to
          have the hook rebuild it for the new
          version, since it won't overwrite an
          existing one. After this, reload the
          development shell to rebuild it.
          You'll see a warning asking you to
          do this when version mismatches are
          present. For safety, removal should
          be a manual step, even if trivial.
        */
        pythonVersion = "3.13";
      in
        {
          devShells = let
            concatMajorMinor =
              v:
              lib.pipe v [
                lib.versions.splitVersion
                (lib.sublist 0 2)
                lib.concatStrings
              ];

            python = pkgs."python${concatMajorMinor pythonVersion}";
          in {
            default = pkgs.mkShellNoCC {
              venvDir = ".venv";

              postShellHook = ''
                venvVersionWarn() {
                	local venvVersion
                	venvVersion="$("$venvDir/bin/python" -c 'import platform; print(platform.python_version())')"

                	[[ "$venvVersion" == "${python.version}" ]] && return

                	cat <<EOF
                Warning: Python version mismatch: [$venvVersion (venv)] != [${python.version}]
                         Delete '$venvDir' and reload to rebuild for version ${python.version}
                EOF
                }

                venvVersionWarn
              '';

              packages =
                (with python.pkgs; [
                  venvShellHook
                  pip
                ]);
            };
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
