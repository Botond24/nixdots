{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
let
  autostartEntry =
    pkg:
    let
      names =
        if (builtins.isAttrs pkg) then
          {
            name = pkg.name;
            pkg =
              if (builtins.hasAttr "pkgName" pkg) then
                pkg."${pkg.pkgName}"
              else
                (if (builtins.hasAttr "pkg" pkg) then pkg.pkg else pkgs."${pkg.name}");
          }
        else
          {
            name = pkg;
            pkg = pkgs."${pkg}";
          };
      path = "${names.pkg}/share/applications";
      name = names.name;
      paths = map (x: path + "/${x}") (builtins.attrNames (builtins.readDir path));
      desktop = lib.findFirst (
        x: builtins.match ".*${name}\\.desktop$" x != null
      ) "${name}.desktop not found" paths;
    in
      desktop;

  autostartEntries = builtins.map autostartEntry;
  stdenv = pkgs.stdenv;



  system = stdenv.hostPlatform.system;

  pluginList = [
    "com.fapiko.jetbrains.plugins.better_direnv"
    "com.github.copilot"
    "com.github.deeepamin.gitlabciaid"
    "org.jetbrains.plugins.gitlab"
    "io.github.salatmaster.direnv"
  ];
in
{
  imports = [
    ./flatpak.nix
    ./shell.nix
    ./nixcord.nix
    ./spicetify.nix
    ./emacs.nix
    ./niri
  ];

  home.username = "button";
  home.homeDirectory = "/home/button";
  home.packages = with pkgs; [
    zip
    unzip
    rar
    fastfetch
    nixd
    nixfmt
    vlc
    wl-clipboard
    tealdeer
    keepassxc
    pinta

    (inputs.nix-jetbrains-plugins.lib.buildIdeWithPlugins pkgs "idea" pluginList)
    kicad
    prusa-slicer
    openrgb-with-all-plugins

    easyeffects
    deepfilternet
    wayvnc
    bs-manager
    (prismlauncher.override {
      additionalPrograms = [ ffmpeg ];
      jdks = with javaPackages.compiler; [
        temurin-bin.jre-25
        temurin-bin.jre-21
        openjdk8-bootstrap
        openjdk11-bootstrap
        openjdk17-bootstrap
      ];
    })
    inputs.hytale-launcher.packages.${system}.default
    (heroic.override {
      extraPkgs =
        pkgs': with pkgs'; [
          gamescope
          gamemode
        ];
    })
  ];

  programs.firefox = {
    enable = true;
    nativeMessagingHosts = [ pkgs.keepassxc pkgs.fx-cast-bridge ];
  };

  programs.zed-editor = {
    enable = true;
  };

  home.enableNixpkgsReleaseCheck = false;
  home.file.".local/share/PrismLauncher/instances".source =
    config.lib.file.mkOutOfStoreSymlink "/media/SSD2TB/Games/minecraft/instances";

  services.playerctld.enable = true;

  xdg = {
    enable = true;
    autostart = {
      enable = true;
      readOnly = true;
      entries = autostartEntries [
        "vesktop"
        "solaar"
        {name = "org.openrgb.OpenRGB"; pkg = pkgs.openrgb-with-all-plugins;}
        {name = "org.keepassxc.KeePassXC"; pkg = pkgs.keepassxc;}
      ];
    };
  };

  # systemd.user.services."wayvnc" = {
  #   Unit = {
  #     Description = "wayvnc VNC server";
  #     Documentation = [ "man:wayvnc(1)" ];
  #     After = [ config.wayland.systemd.target ];
  #     PartOf = [ config.wayland.systemd.target ];
  #   };
  #   Install.WantedBy = [ config.wayland.systemd.target ];
  #   Service.ExecStart = "${lib.getExe pkgs.wayvnc} -d";
  # };
  # xdg.configFile."wayvnc/config".text = ''
  #   address=0.0.0.0
  #   port=5901
  # '';

  xdg.configFile."tigervnc/passwd".source = "${inputs.ssh}/tigervnc/passwd";
  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "26.05";
}
