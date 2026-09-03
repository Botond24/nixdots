{
  config,
  path,
  lib,
  ...
}:
{
  settings ={
    services = {
      mealie ={
        service = {
          image = "ghcr.io/mealie-recipes/mealie:latest";
          restart = "unless-stopped";
          ports = [
            "9000:9000"
          ];
          volumes = [
            "${config.custom.dataPath}/mealie:/app/data"
          ];
          environment = {
            "ALLOW_SIGNUP" = "false";
            "PUID" = "1000";
            "PGID" = "100";
            "TZ" = "Europe/Amsterdam";
            "BASE_URL" = "https://meal.bttn.dev";
          };
          networks = [
            config.custom.traefikNetwork
          ];
          labels = lib.custom.traefikDomainless "meal" 9000;
        };
      };
    };
  };
}
