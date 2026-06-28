{
  buildPythonApplication,
  fetchFromGitHub,
  keyboard,
  openrgb-python,
  watchdog,
  pyyaml,
  i3ipc,
  pkgs
}: buildPythonApplication {
  pname = "openrgb-keyboard-highlighter";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "DuckTapeMan35";
    repo = "openrgb-keyboard-highlighter";
    rev = "ab11a7a2efafd9183dd67c7eaa5903b022d996c4";
    hash = "sha256-ywbi8h2xqxtxIdfh0HbTNyOJjW2f8L8dV5SW7Jy72d8=";
  };

  format = "other";

  dontBuild = true;
  dontConfigure = true;

  propagatedBuildInputs = [
     keyboard
     openrgb-python
     watchdog
     pyyaml
     i3ipc
  ];

  nativeBuildInputs = [
    pkgs.makeWrapper
  ];

  buildInputs = [
    pkgs.kbd
  ];

  patches = [
    ./001-env.patch
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    install -m755 openrgb_highlighter $out/bin/openrgb-highlighter

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/openrgb-highlighter \
      --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.kbd ]}
  '';
}
