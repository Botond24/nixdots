{
  pkgs,
  package,
  config,
  lib ? pkgs.lib,
}:
let
  cfg = config.services.openrgb-highlighter;
in
{
  options.services.openrgb-highlighter = {
    enable = lib.mkEnableOption "openrgb-highlighter";
    settings = lib.mkOption {
      type = lib.types.attrs;
      default = {
        pywall = false;
        window_manager = "i3";
        key_positions = {
          super = "left windows";
          enter = "enter";
          shift = [
            "left shift"
            "right shift"
          ];
          numbers = [
            "1"
            "2"
            "3"
            "4"
            "5"
            "6"
            "7"
            "8"
            "9"
            "0"
          ];
          arrows = [
            "right arrow"
            "left arrow"
            "up arrow"
            "down arrow"
          ];

        };
        modes = {
          base = {
            rules = [
              {
                keys = [ "all" ];
                color = "(0,255,0)";
              }
            ];
          };
        };
      };
      description = "Config for the highlighter.";
    };
    display = lib.mkOption {
      type = lib.types.str;
      default = ":0";
    };
    user = lib.mkOption {
      type = lib.types.str;
      default = builtins.head builtins.attrNames config.users.users;
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = package;
      defaultText = lib.literalExpression "pkgs.openrgb-highlighter";
      description = "The package to use.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.openrgb-highlighter = {
      description = "Keyboard Highlighter Service";
      after = [
        "graphical.target"
        "display-manager.service"
      ];
      wants = [ "graphical.target" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Type = "simple";
        User = "root";
        ExecStart = "${cfg.package}/bin/openrgb-highlighter";
      };
      environment = {
        DISPLAY = cfg.display;
        USER = cfg.user;
      };
    };
    systemd.tmpfiles.rules = (
      let
        cfgFile = (pkgs.formats.yaml { }).generate "config.yaml" cfg.settings;
        cfgLocation = "${config.users.users."${cfg.user}".home}/.config/openrgb-keyboard-highlighter";
      in
      [
        "d ${cfgLocation} 0755 ${cfg.user} users -"
        "L+ ${cfgLocation}/config.yaml - - - - ${cfgFile}"
      ]
    );
  };
}
