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
    ];
    uninstallUnused = true;
  };
}
