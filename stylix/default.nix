{
  inputs,
  pkgs,
  lib,
  ...
}: let

  headInt = str: lib.toIntBase10 (builtins.substring 0 1 str);
  imageFromStr = dir: str: let
    paths =  map (x: dir + "/${x}") (builtins.attrNames (builtins.readDir dir));

    sl = builtins.stringLength str;
    rest = builtins.substring 1 sl str;

    selectedIdx = (headInt str)-1;
    selectedPath = builtins.elemAt paths selectedIdx;
  in
    if sl == 1 then selectedPath else imageFromStr selectedPath rest;


  # Change this for new image
  # 13
  # 14
  # 15
  # 16
  # 11
  # NEVER 12 😭
  # 21
  # 22
  image = imageFromStr ../wallpapers imgStr;
  imgStr = "16";
in {
  imports = [
    inputs.stylix.nixosModules.stylix
  ];

  stylix = {
    enable = true;
    #base16Scheme = "${pkgs.base16-schemes}/share/themes/dracula.yaml";
    image = image;
    polarity = "dark";
    fonts = rec {
      sansSerif = {
        package = pkgs.lato;
        name = "Lato";
      };
      serif = {
        package = pkgs.geist-font;
        name = "Geist Serif";
      };
      monospace = {
        package = pkgs.nerd-fonts.space-mono;
        name = "SpaceMono Nerd Font";
      };
      emoji = {
        package = pkgs.twemoji-color-font;
        name = "Twitter Color Emoji";
      };
    };
    icons = {
      enable = true;
      package = pkgs.dracula-icon-theme;
      dark = "Dracula";
    };
    cursor = {
      package = pkgs.nordzy-cursor-theme;
      size = 24;
      name = "Nordzy-cursors";
    };
    opacity = {
      popups = 0.5;
      terminal = 0.5;
    };
  };
}
