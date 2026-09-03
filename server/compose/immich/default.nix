{
  config,
  lib,
  path,
  inputs,
  ...
}: let
  secrets = builtins.fromJSON (builtins.readFile "${inputs.ssh}/compose/immich.json");
in {
  settings = {
    services = {
      immich-server = {
        service = {
          image = "ghcr.io/immich-app/immich-server:release";
          volumes = [
            #"/mnt/images:/data"
            "/etc/localtime:/etc/localtime:ro"
          ];
          ports = [
            "2283:2283"
          ];
          devices = [
            "/dev/dri:/dev/dri"
          ];
          depends_on = [
            "redis"
            "database"
          ];
          restart = "always";
          environment = secrets;
          networks = [
            config.custom.traefikNetwork
            "default"
          ];
          labels = lib.custom.traefikDomainless "immich" 2283;
        };
        out.service.group_add = [
          config.users.groups.render.gid
        ];
      };

      immich-machine-learning = {
        service = {
          image = "ghcr.io/immich-app/immich-machine-learning:release";
          volumes = [
            "/var/cache/immich:/cache"
          ];
          devices = [
            "/dev/dri:/dev/dri"
          ];
          restart = "always";
          environment = secrets;
          labels = {
            "traefik.enable" = "false";
          };
        };
        out.service.group_add = [
          config.users.groups.render.gid
        ];
      };

      redis.service = {
        image = "docker.io/valkey/valkey:9@sha256:8e8d64b405ce18f41b8e5ee20aa4687a8ed0022d1298f2ce31cdcf3a76e09411";

        healthcheck = {
          test = [
            "CMD-SHELL"
            "redis-cli ping || exit 1"
          ];
        };
        restart = "always";
        labels = {
          "traefik.enable" = "false";
        };
      };
      database.service = {
        image = "ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0@sha256:bcf63357191b76a916ae5eb93464d65c07511da41e3bf7a8416db519b40b1c23";

        environment = {
          "POSTGRES_PASSWORD" = secrets."DB_PASSWORD";
          "POSTGRES_USER" = secrets."DB_USERNAME";
          "POSTGRES_DB" = secrets."DB_DATABASE_NAME";
          "POSTGRES_INITDB_ARGS" = "--data-checksums";
        };
        volumes = [
          "${config.custom.dataPath}/immich-db:/var/lib/postgresql/data"
        ];
        labels = {
          "traefik.enable" = "false";
        };
      };
    };
  };
}
