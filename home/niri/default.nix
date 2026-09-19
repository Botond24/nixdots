{
  inputs,
  pkgs,
  lib,
  ...
}: let
  generateFolder = name: f: let
    files = map (x: name + "/" + x) (builtins.filter f (builtins.attrNames (builtins.readDir (./.))));
  in builtins.listToAttrs (map (x: {name = x; value = { source = (./. + "/${x}");};}) files);

  stdenv = pkgs.stdenv;
  system = stdenv.hostPlatform.system;
in{
  xdg.configFile = generateFolder "niri" (x: ! builtins.isNull (builtins.match "kdl$" x)) // {
    "niri/generated.kdl".text = lib.hm.generators.toKDL {} {
      "spawn-at-startup" = "${lib.getExe inputs.openrgb-highlighter.packages.${system}.default}";
    };
  };
  programs.fuzzel = {
    enable = true;
  };
}
