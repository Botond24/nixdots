{
  path,
  lib,
  config,
  ...
}:
{
  settings = {
    services = {
      homepage = {
        service = {
          image = "ghcr.io/gethomepage/homepage";
          volumes = [
            "${path}/homepage:/app/config"
            "/var/run/docker.sock:/var/run/docker.sock:ro"
          ];
          restart= "unless-stopped";
          ports = [
            "3000:3000"
          ];
          environment = {
            HOMEPAGE_ALLOWED_HOSTS = "0.0.0.0:3000,${config.custom.localDomain}"; #list with comma seperated entries
          };
          networks = [
            config.custom.traefikNetwork
          ];
          labels = lib.custom.traefikLocal "homepage" 3000 // { "${lib.custom.traefikRouter "homepage"}.rule" = lib.custom.traefikHost config.custom.localDomain; };
        };
      };

      traefik = {
        service = {
          image = "traefik";
          ports = [
            "80:80"
            "8080:8080"
          ];
          volumes = [
            "/var/run/docker.sock:/var/run/docker.sock:ro"
            "${path}/traefik.yml:/etc/traefik/traefik.yml"
          ];
          networks = [
            config.custom.traefikNetwork
          ];
          labels = lib.custom.traefikLocal "traefik" 8080;
        };
      };
    };
    networks."${config.custom.traefikNetwork}".name = config.custom.traefikNetwork;
  };
}
