{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  secrets = builtins.fromJSON (builtins.readFile "${inputs.ssh}/compose/ddns.json");
  services = config.virtualisation.arion.projects;

  domainMap = domain: lib.concatLists (
    lib.mapAttrsToList
      (name: value:
        lib.mapAttrsToList
          (subname: service: (lib.filterAttrs (n: v: builtins.match "rule$" n) service.labels) or {})
          value.settings.services
      )
      services
  );

  domainForService domain: service: lib.mapAttrsToList (n: v: lib.mapAttrsToList (n: v: ) (lib.filterAttrs (n: v: builtins.match "rule$" n) ((v.settins.services.${service} or {service.labels = {}}).service.labels)))

  secretMap = domain: value@{ protocol, ... }: "protocol=${protocol} \\\n" + lib.join "\n" (
    lib.attrsets.mapAttrsToList (n: v: n + "${if lib.isString v then v else toString v} \\")
      (lib.filterAttrs (n: v: n == "protocol") value)
  ) + "\n" + domainMap domain;

  generated = lib.mapAttrsToList

  configFile = pkgs.writeText ''
daemon=300
ssl=yes
use=web
${generated}
'';

in {
  settings.services = {
    ddclient.service = {
      image = "lscr.io/linuxserver/ddclient";
      environment = {
        PUID = "1000";
        PGID = "100";
        TZ = config.time.timeZone;
      };

    };
  };
}
