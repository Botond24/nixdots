{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  custom-sddm-astronaut = pkgs.sddm-astronaut.override {
    embeddedTheme = "black_hole";
  };

in {
  services.displayManager.sddm = {
    enable = true;
    extraPackages = [
      custom-sddm-astronaut
     ];

    theme = "sddm-astronaut-theme";
    settings = {
      Theme = {
        Current = "sddm-astronaut-theme";
      };
      General = {
        Numlock = "on";
      };
    };
  };


  environment.systemPackages =[
    custom-sddm-astronaut
  ];
}