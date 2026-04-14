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
      paths = builtins.map (x: path + "/" + x) (builtins.attrNames (builtins.readDir path));
      desktop = lib.findFirst (
        x: builtins.match ".*${name}\\.desktop$" x != null
      ) "${name}.desktop not found" paths;
    in
    desktop;
  autostartEntries = builtins.map autostartEntry;
in
{
  imports = [
    ./flatpak.nix
    ./shell.nix
    ./nixcord.nix
    ./spicetify.nix
  ];
  home.username = "button";
  home.homeDirectory = "/home/button";
  home.packages = with pkgs; [
    nmap
    zip
    unzip
    fastfetch
    nil
    vlc
    easyeffects
    deepfilternet
    wl-clipboard
    tealdeer
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
    inputs.hytale-launcher.packages.${pkgs.system}.default
    (heroic.override {
      extraPkgs =
        pkgs': with pkgs'; [
          gamescope
          gamemode
        ];
    })
    rar
  ];

  programs.firefox.enable = true;

  home.enableNixpkgsReleaseCheck = false;
  home.file.".local/share/PrismLauncher/instances".source =
    config.lib.file.mkOutOfStoreSymlink "/media/SSD2TB/Games/minecraft/instances";
  home.file.".emacs.d/init.el".source = ./emacs.el;
  home.file.".emacs.d/custom.el".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nixos/home/custom.el";

  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
    extraPackages =
      epkgs: with epkgs; [
        nix-mode
        nixfmt
        nushell-mode
        platformio-mode
        smex
        multiple-cursors
        company
        c-eldoc
        markdown-mode
        lsp-mode
        go-mode
        d-mode
        pkgs.emacs-all-the-icons-fonts
        smartparens
      ];
  };

  xdg = {
    enable = true;
    autostart = {
      enable = true;
      readOnly = true;
      entries = autostartEntries [
        "vesktop"
        "steam"
        "easyeffects"
        "solaar"
      ];
    };
    desktopEntries = {

    };
  };

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "26.05";
}
