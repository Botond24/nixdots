{
  config,
  path,
  lib,
  ...
}:
{
  settings = {
    services = {
      jellyfin = {
        service = {
          image = "jellyfin/jellyfin";
          volumes = [
            "${config.custom.dataPath}/jellyfin:/config"
            "${path}/config:/config/config"
            "/var/cache/jellyfin:/cache"
            /*{
            type = "bind";
            source = "/mnt/jelly";
            tagret = "/media";
          }*/
          ];
          restart= "unless-stopped";
          ports = [
            "8096:8096/tcp"
            "7359:7359/udp"
          ];
          devices = [
            "/dev/dri:/dev/dri"
          ];
          networks = [
            config.custom.traefikNetwork
          ];
          labels = lib.custom.traefikDomainless "jelly" 8096;
        };
        out.service.group_add = [
          config.users.groups.render.gid
        ];
      };
    };
  };
}
