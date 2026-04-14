{
  pkgs,
  ...
}:
let
  custom-sddm-astronaut = pkgs.sddm-astronaut.override {
    embeddedTheme = "black_hole";
  };

in
{
  services.displayManager.sddm = {
    enable = true;
    extraPackages = [
      custom-sddm-astronaut
    ];

    autoNumlock = true;

    theme = "sddm-astronaut-theme";
    settings = {
      Theme = {
        Current = "sddm-astronaut-theme";
      };
    };
  };

  environment.systemPackages = [
    custom-sddm-astronaut
  ];
}
