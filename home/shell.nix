{
  pkgs,
  lib,
  config,
  ...
}:
let
  homePath = config.home.profileDirectory;
  nu_scripts_path = "${pkgs.nu_scripts}/share/nu_scripts";
  complConf =
    completions:
    let
      # get the paths of all completions[n]
      paths = builtins.map (
        x:
        builtins.map (y: nu_scripts_path + "/custom-completions/" + x + "/" + y) (
          builtins.attrNames (builtins.readDir (nu_scripts_path + "/custom-completions/" + x))
        )
      ) completions;

      # filter out non .nu files under each path in paths
      files = lib.flatten (
        builtins.map (y: builtins.filter (x: ((builtins.match ".*\\.nu" x) != null)) y) paths
      );
    in
    # concat them for the config
    "\n" + lib.concatLines (builtins.map (x: "source " + x) files);
in
{
  home.shell.enableNushellIntegration = true;
  programs.zoxide.enable = true;

  programs.nushell = {
    enable = true;
    shellAliases = {
      cd = "z";
      "cd --" = "z ~";
      "cd ssd" = "z /media/SSD2TB";
      "config nix" = "emacs ~/.config/nixos";
      "config emacs" = "emacs ~/.config/nixos/home/emacs.el";
      "config nu" = "emacs ~/.config/nixos/home/config.nu";
      "nr" = "nixos-rebuild -S";
      "nr s" = "nr switch";
    };
    configFile.source = ./config.nu;

    extraConfig = complConf [
      "zoxide"
      "ssh"
      "curl"
      "git"
      "make"
      "man"
      "nano"
      "tldr"
    ];
  };
  home.packages = with pkgs; [
    nu_scripts
    fish
    nmap
    zip
    unzip
    fastfetch
    wl-clipboard
    tealdeer
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableNushellIntegration = true;
  };

  programs.kitty = {
    enable = true;
    enableGitIntegration = true;
    keybindings = {
      "ctrl+c" = "copy_or_interrupt";
      "ctrl+tab" = "next_tab";
      "ctrl+shift+tab" = "previous_tab";
      "ctrl+t" = "new_tab";
      "ctrl+w" = "close_tab";
    };
    settings = {
      shell = "${homePath}/bin/nu";

      tab_bar_edge = "top";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      tab_title_template = "{fmt.fg.red}{bell_symbol}{activity_symbol}{fmt.fg.tab}{tab.last_focused_progress_percent}{title}|{tab.active_exe}";

      enable_audio_bell = false;
      cursor_shape = "beam";
      foreground = "#dddddd";
      background = "#181818";
      selection_foreground = "#000000";
      selection_background = "#fffacd";
      background_opacity = 0.5;
      background_blur = 1;
    };
  };
  programs.starship = {
    enable = true;
    presets = [ "nerd-font-symbols" ];
  };

  programs.zsh = {
    #  enable = true;
    enableVteIntegration = true;
    autosuggestion.enable = true;
    defaultKeymap = "emacs";
    shellAliases = {
      ls = "ls --color=auto";
      cd = "z";
      "cd --" = "z ~";
    };
    dirHashes = {
      ssd = "/media/SSD2TB";
    };
    initContent = ''
      . ${./zinputrc}
      eval $(dircolors -b)
    '';
    plugins = with pkgs; [
      jq-zsh-plugin
    ];
  };
  programs.intelli-shell.enable = true;
}
