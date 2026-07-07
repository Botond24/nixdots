{
  pkgs,
  inputs,
  ...
}:
{
  services.desktopManager.plasma6.enable = true;
  environment.plasma6 = {
    excludePackages = with pkgs.kdePackages; [
      konsole
      discover
    ];
  };
  programs.partition-manager.enable = true;
  services.xserver.enable = true;

  programs.niri.enable = true;
  services.gnome.gcr-ssh-agent.enable = false;
}
