{
  inputs,
  lib,
  config,
  ...
}: let
  cfg = config.custom;

  newlib = {
    custom = {
      inherit traefikHost;
      inherit traefikRouter;
      inherit traefikServices;
      inherit traefikLabels;
      inherit traefikLocal;
      inherit traefikDomainless;
      inherit traefikDefaultLabels;
      inherit compose;
      inherit traefikCompose;
    };
  };
  traefikHost = domains:
    if builtins.isList domains && builtins.length domains > 1 then
      let hosts = (map (x: "Host(`${x}`)") domains);
      in lib.join " || " hosts
    else if builtins.isString domains then
      "Host(`${domains}`)"
    else
      "Host(`${builtins.head domains}`)";

  traefikRouter = name: "traefik.http.routers.${name}";

  traefikServices = name: "traefik.http.services.${name}.loadbalancer";

  traefikLabels = name: port: domains: {
    "traefik.enable"  = "true";
    "${traefikRouter name}.rule" = traefikHost (if builtins.isList domains then (map (x: "${name}.${x}") domains) else "${name}.${domains}");
    "${traefikServices name}.server.port" = "${if builtins.isString port then port else toString port}";
    "traefik.docker.network" = cfg.traefikNetwork;
  };

  traefikLocal = name: port: traefikLabels name port cfg.localDomain;

  traefikDomainless = name: port: traefikLabels name port cfg.domains;

  traefikDefaultLabels = name: traefikDomainless name 80;

  compose = path: config: name: { "${name}" = import "${toString ./.}/compose/${name}" { inherit inputs; inherit config; lib = lib // newlib; path = "${path}/${name}"; }; };
  traefikCompose = path: config: name: let
    base = compose path config name;
  in lib.attrsets.recursiveUpdate base  {
    "${name}".settings.networks = {
      "${cfg.traefikNetwork}" = {
        external = true;
        name = cfg.traefikNetwork;
      };
    };
  };
in {
  options.custom = {
    localDomain = lib.mkOption {
      default = "servereon.local";
      type = lib.types.separatedString ".";
    };
    domains = lib.mkOption {
      default = [ config.custom.localDomain ];
      type = lib.types.nonEmptyListOf (lib.types.separatedString ".");
    };
    dataPath = lib.mkOption {
      default = "/var/lib/compose";
      type = lib.types.pathWith {};
    };
    traefikNetwork = lib.mkOption {
      default = "proxy";
      type = lib.types.str;
    };
  };

  config = {
    nixpkgs.overlays = [
      (f: p: {lib = p.lib // newlib;})
    ];
    systemd.tmpfiles.rules = [
      "d ${config.custom.dataPath} 0755 root root -"
    ];
  };
}
