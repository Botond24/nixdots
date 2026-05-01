{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  importNpmLock,
  pkgs,
}:

buildNpmPackage (finalAttrs: {
  pname = "spreen";
  version = "simple";

  src = fetchFromGitHub {
    owner = "IshaanOhri";
    repo = "Spreen";
    tag = finalAttrs.version;
    hash = "sha256-6uhVEWMiGiNyESXBaJS2Oiz9yNal38557/OPiOrd39M=";
  };

  npmDepsHash = "sha256-0pyTWYMNz7ldo6AxwaS3Yi5eaFV1BDaDRSxPNmMYiaM=";

  dontNpmBuild = true;

  npmDeps = importNpmLock { npmRoot = finalAttrs.src; };

  npmConfigHook = importNpmLock.npmConfigHook;

  patches = [
    ./log.patch
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/${finalAttrs.pname}
    cp -r . $out/lib/${finalAttrs.pname}

    mkdir -p $out/bin
    cat > $out/bin/spreen <<EOF
    #!${lib.getExe pkgs.bash}
    cd $out/lib/${finalAttrs.pname}
    exec ./node_modules/.bin/env-cmd -f ./src/config/dev.env \
         ./node_modules/.bin/ts-node ./src/app.ts
    EOF

    chmod +x $out/bin/spreen

    runHook postInstall
  '';

  meta = {
    description = "Now use any device with a web browser as a second screen for your laptop or PC. No cables. No internet. No software installation. Just Spreen, that's it";
    homepage = "https://github.com/IshaanOhri/Spreen";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "spreen";
    platforms = lib.platforms.all;
  };
})
