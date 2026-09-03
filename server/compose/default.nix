{
  config,
  path,
  pkgs,
  ...
}: let
  compose = pkgs.lib.custom.compose path config;
  traefikCompose = pkgs.lib.custom.traefikCompose path config;
in
  traefikCompose "jellyfin" //
  compose "management" //
#  compose "arr" //
  traefikCompose "immich" //
  traefikCompose "mealie" //
  compose "ddns"
