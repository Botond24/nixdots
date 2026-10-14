{
  pkgs,
  lib,
  ...
}:
let
  custom-sddm-astronaut = pkgs.sddm-astronaut.override {
    embeddedTheme = "black_hole";
  };

in
{
  /*services.displayManager.sddm = {
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
  ];*/

  services.accounts-daemon.enable = true;

  services.displayManager.regreet = {
    enable = true;
    package = lib.mkForce (pkgs.regreet.overrideAttrs (oldAttrs: {
      nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];

      postInstall = (oldAttrs.postInstall or "") + ''
        wrapProgram $out/bin/regreet \
          --set GTK_USE_PORTAL "0" \
          --set GDK_DEBUG "no-portals" \
          --set GSK_RENDERER "gl" \
          --add-flags "-v"
      '';
    }));
    cageArgs = [ "-s" "-d" "-m" "last" ];
  };
}
