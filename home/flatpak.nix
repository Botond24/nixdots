{
inputs,
pkgs,
...
}: {
  imports = [
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
  ];
  services.flatpak = {
    update.auto.enable = true;
    packages = [
      "com.viber.Viber"
      "org.vinegarhq.Sober"
      "org.vinegarhq.Vinegar"
      (rec {
        appId = "com.hypixel.HytaleLauncher";
        sha256 = "8b6f49136fdabca97ee83a70cc3e4770718c16bdd119e159cea13f88902e5a24";
        bundle = "${pkgs.fetchurl {
          url = "https://launcher.hytale.com/builds/release/linux/amd64/hytale-launcher-latest.flatpak";
          inherit sha256;
        }}";
      })
    ];
    uninstallUnused = true;
  };
}
