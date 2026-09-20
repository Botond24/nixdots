{
  pkgs,
  lib,
  config,
  ...
}: let
  buildMozillaXpiAddon = pkgs.nur.repos.rycee.firefox-addons.buildFirefoxXpiAddon;
  google-search-maps-button = buildMozillaXpiAddon {
    pname = "google-search-maps-button";
    version = "1.2.4";
    addonId = "{884f845b-914f-4069-ad5b-b8bf870249fc}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4649137/google_search_maps_button-1.2.4.xpi";
    sha256 = "pzpSJ/jjxpHpmz7eXpg4jz2wWMCmZmHZJdxAJPqrBWo=";
    meta = with lib;
      {
        description = "Adds back the Maps button to Google search pages and makes the map images clickable again for seamless navigation.";
        license = licenses.mit;
        mozPermissions = [
          "https://www.google.com/*"
          "https://www.google.co.uk/*"
          "https://www.google.co.jp/*"
          "https://www.google.com.au/*"
          "https://www.google.at/*"
          "https://www.google.be/*"
          "https://www.google.bg/*"
          "https://www.google.hr/*"
          "https://www.google.cy/*"
          "https://www.google.cz/*"
          "https://www.google.dk/*"
          "https://www.google.ee/*"
          "https://www.google.fi/*"
          "https://www.google.fr/*"
          "https://www.google.de/*"
          "https://www.google.gr/*"
          "https://www.google.hu/*"
          "https://www.google.ie/*"
          "https://www.google.it/*"
          "https://www.google.lv/*"
          "https://www.google.lt/*"
          "https://www.google.lu/*"
          "https://www.google.mt/*"
          "https://www.google.nl/*"
          "https://www.google.pl/*"
          "https://www.google.pt/*"
          "https://www.google.ro/*"
          "https://www.google.sk/*"
          "https://www.google.si/*"
          "https://www.google.es/*"
          "https://www.google.se/*"
          "https://www.google.is/*"
          "https://www.google.li/*"
          "https://www.google.no/*"
          "https://www.google.sm/*"
          "https://www.google.ch/*"
          "https://www.google.com.ua/*"
          "https://www.google.rs/*"
          "https://www.google.me/*"
          "https://www.google.ba/*"
          "https://www.google.mk/*"
          "https://www.google.md/*"
          "https://www.google.by/*"
          "https://www.google.ad/*"
          "https://www.google.mc/*"
        ];
        platforms = platforms.all;
      };
  };
in {
  programs.firefox = {
    enable = true;
    nativeMessagingHosts = [ pkgs.keepassxc pkgs.fx-cast-bridge ];
    profiles.regular = {
      id = 0;
      isDefault = true;

      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        keepassxc-browser
        ublock-origin
        darkreader
        i-dont-care-about-cookies
        sponsorblock
        return-youtube-dislikes
        google-search-maps-button
      ];

      settings = {
        "browser.download.viewableInternally.typeWasRegistered.avif" = true;
        "browser.download.viewableInternally.typeWasRegistered.webp" = true;
        "browser.ml.linkPreview.enabled" = false;
        "browser.ml.onnxNativeAvailabilityReported" = true;
        "browser.newtabpage.pinned" = [
            {
              label = "YouTube";
              url = "https://youtube.com";
            }
            {
              label = "GitHub";
              url = "https://github.com";
            }
            {
              label = "Brightspace";
              url = "https://brightspace.rug.nl";
            }
            {
              label = "Email";
              url = "https://mail.github.com";
            }
        ];
        "browser.newtabpage.activity-stream.newtabWallpapers.wallpaper" = "custom";
        "browser.newtabpage.activity-stream.newtabWallpapers.customWallpaperURL" = "path://${config.stylix.image}";
        "browser.newtabpage.activity-stream.showWeather" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredCheckboxes" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.startup.couldRestoreSession.count" = 2;
        "browser.translations.neverTranslateLanguages" = "hu";
        "browser.uiCustomization.state" = {
          "placements" = {
            "nav-bar" = [
              "back-button"
              "forward-button"
              "stop-reload-button"
              "customizableui-special-spring1"
              "vertical-spacer"
              "urlbar-container"
              "customizableui-special-spring2"
              "downloads-button"
              "reset-pbm-toolbar-button"
              "unified-extensions-button"
            ];
            "TabsToolbar" = [
              "tabbrowser-tabs"
              "new-tab-button"
              "customizableui-special-spring3"
              "alltabs-button"
            ];
          };
          "currentVersion" = 26;
        };
        "browser.urlbar.placeholderName" = "Google";
        "browser.urlbar.placeholderName.private" = "Google";
        "browser.urlbar.suggest.trending" = false;
        "devtools.toolbox.host" = "right";
        "doh-rollout.home-region" = "NL";
        "dom.forms.autocomplete.formautofill" = true;
        "media.eme.enabled" = true;
        "privacy.bounceTrackingProtection.hasMigratedUserActivationData" = true;
        "privacy.globalprivacycontrol.enabled" = true;
        "privacy.globalprivacycontrol.was_ever_enabled" = true;
      };
      search  = {
        default = "google";
        force = true;
        order = [
          "google"
          "github"
          "nix-packages"
          "nix-options"
          "home-options"
          "wolfram"
          "github"
        ];
        engines = {
          nix-packages = {
            name = "Nix Packages";
            urls = [{
              template = "https://search.nixos.org/packages";
              params = [
                { name = "type"; value = "packages"; }
                { name = "channel"; value = "unstable"; }
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };
          nix-options = {
            name = "Nix Options";
            urls = [{
              template = "https://search.nixos.org/options";
              params = [
                { name = "type"; value = "options"; }
                { name = "channel"; value = "unstable"; }
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@no" ];
          };
          home-options = {
            name = "HomeManager Options";
            urls = [{
              template = "https://search.nixos.org/options";
              params = [
                { name = "type"; value = "options"; }
                { name = "channel"; value = "unstable"; }
                { name = "source"; value = "home_manager"; }
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@hm" ];
          };
          github = {
            name = "Github";
            urls = [{
              template = "https://github.com/search";
              params = [
                { name = "q"; value = "{searchTerms}"; }
              ];
            }];
            iconMapObj."16" = "https://github.githubassets.com/favicons/favicon-dark.png";
            definedAliases = [ "@gh" ];
          };
          wolfram = {
            name = "Wolfram Alpha";
            urls = [{
              template = "https://wolframalpha.com/input";
              params = [
                { name = "i"; value = "{searchTerms}"; }
              ];
            }];
            iconMapObj."16" = "https://www.google.com/s2/favicons?domain=wolframalpha.com";
            definedAliases = [ "@wa" ];
          };
          bing.metaData.hidden = true;
          ddg.metaData.hidden = true;
          ecosia.metaData.hidden = true;
          amazon.metaData.hidden = true;
          "ebay@search.mozilla.orgdefault".metaData.hidden = true;
          perplexity.metaData.hidden = true;
          "qwant@search.mozilla.orgdefault".metaData.hidden = true;
          "startpage@search.mozilla.orgdefault".metaData.hidden = true;
          "wikipedia@search.mozilla.orgdefault".metaData.hidden = true;
        };
      };
      handlers.force = true;
      handlers.mimeTypes."application/pdf" = {
        action = 2;
        ask = false;
        handlers = [
          {
            name = "Okular";
              path = "${pkgs.kdePackages.okular}/bin/okular";
          }
        ];
        extensions = [ "pdf" ];
      };
      handlers.schemes.mailto = {
        action = 2;
        ask = false;
        handlers = [
          {
            name = "Gmail";
            uriTemplate = "https://mail.google.com/mail/?extsrc=mailto&url=%s";
          }
        ];
      };

    };

    policies = {
      AIControls.Default.Value = "blocked";
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      BrowserDataBackup = {
        AllowBackup = false;
        AllowRestore = false;
      };
      CaptivePortal = false;
      Cookies.Behavior = "reject-tracker-and-partition-foreign";
      DisableProfileImport = true;
      DisableSetDesktopBackground = true;
      GenerativeAI.Enabled = false;
      PictureInPicture.Enabled = true;
    };
  };
  stylix.targets.firefox.profileNames = [ "regular" ];
}
