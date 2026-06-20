{ inputs, ... }: {
  networking.hostName = "interloper";
  networking.firewall = {
    enable = true;
  };
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;

  };
  networking.wg-quick.interfaces = {
    servereon = {
      configFile = "${inputs.ssh}/wireguard/servereon.conf";
    };
  };


  networking.networkmanager = {
    enable = true;
    ensureProfiles = {
      environmentFiles = [ "${inputs.ssh}/wireless/secrets" ];
      profiles = let
        default = {name, pass ? null}: {
          connection = {
            id = name;
            type = "wifi";
            permissions = "user:button:";
          };
          wifi = {
            mode = "infrastructure";
            ssid = name;
          };
          wifi-security = {
            auth-alg = "open";
            key-mgmt = "wpa-psk";
          } // (if !isNull pass then { psk = pass; } else {});
          ipv4 = {
            method = "auto";
          };
          ipv6 = {
            addr-gen-mode = "stable-privacy";
            method = "auto";
          };
        };
      in {
        eduroam = default { name = "eduroam"; } // {
          wifi-security = {
            auth-alg="open";
            key-mgmt="wpa-eap";
          };
          "802-1x" = {
            eap="peap";
            identity="$IDEN_SCHOOL";
            password="$PASS_SCHOOL";
            phase2-auth="mschapv2";
          };
        };
        ChickenJockey_5G-1 = default { name = "ChickenJockey_5G-1"; pass = "$PASS_BURG"; };
        ChickenJockey_5G-2 = default { name = "ChickenJockey_5G-2"; pass = "$PASS_BURG"; };
        "ChickenJockey_2.4G" = default { name = "ChickenJockey_2.4G"; pass = "$PASS_BURG"; };
        dokicasa = default { name = "dokicasa"; pass = "$PASS_HUN"; };
        "Wife-fi married" = default { name = "Wife-fi married"; pass = "$PASS_HOME"; };
        "Wife-fi divorced" = default { name = "Wife-fi divorced"; pass = "$PASS_HOME"; };
      };
    };
  };
}
