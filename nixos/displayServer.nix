{
  pkgs,
  inputs,
  lib,
  ...
}:
let
  bigscreen = pkgs.kdePackages.plasma-bigscreen;
in {
  services.desktopManager.plasma6.enable = true;
  environment.plasma6 = {
    excludePackages = with pkgs.kdePackages; [
      konsole
      discover
    ];
  };
  programs.partition-manager.enable = true;
  programs.kdeconnect.enable = true;
  services.xserver.enable = true;


  programs.niri.enable = true;

  services.openrgb-highlighter = {
    enable = true;
    enableService = false;
    user = "button";
    settings = {
      window_manager = "niri";
    };
  };

  services.gnome.gcr-ssh-agent.enable = false;

  services.displayManager.defaultSession = lib.mkForce "plasma";
}
