{
  inputs,
  config,
  ...
}: {
  imports = [
    inputs.plasma-manager.homeModules.plasma-manager
  ];

  programs.elisa.enable = false;
  programs.kate = {
    enable = true;
    editor = {
      brackets.automaticallyAddClosing = true;
      brackets.highlightMatching = true;
      font.family = config.stylix.fonts.monospace.name;
      font.pointSize = 10;
      indent.tabFromEverywhere = true;
    };
  };
  programs.konsole.enable = false;
  programs.okular.enable = true;
  programs.plasma = {
    enable = true;
    desktop.mouseActions.rightClick = "contextMenu";
    fonts = {
      fixedWidth.family = config.stylix.fonts.monospace.name;
      fixedWidth.pointSize = 10;
      general.family = config.stylix.fonts.sansSerif.name;
      general.pointSize = 10;
      menu.family = config.stylix.fonts.sansSerif.name;
      menu.pointSize = 10;
      small.family = config.stylix.fonts.sansSerif.name;
      small.pointSize = 8;
      toolbar.family = config.stylix.fonts.sansSerif.name;
      toolbar.pointSize = 10;
      windowTitle.family = config.stylix.fonts.sansSerif.name;
      windowTitle.pointSize = 10;
    };
    input.keyboard.numlockOnStartup = "on";
    # "kpdl:dot"
    input = {
      keyboard.options = [
        "kpdl:dot"
      ];
      touchpads = [
        {
          enable = false;
          name = "ASCE1200:00 04F3:32E2 Touchpad";
          middleButtonEmulation = true;
          productId = "32e2";
          vendorId = "04f3";
        }
      ];
    };
    krunner = {
      position = "center";
      shortcuts.launch = "Meta+Space";
    };
    kscreenlocker = {
      appearance = {
        showMediaControls = true;
        wallpaper = config.stylix.image;
      };
      autoLock = true;
      lockOnResume = true;
      passwordRequired = true;
      passwordRequiredDelay = 5;
      timeout = 10;
    };

    kwin = {
      borderlessMaximizedWindows = false;
      edgeBarrier = 10;
      effects = {
        blur = {
          enable = true;
          noiseStrength = 8;
          strength = 5;
        };
        shakeCursor.enable = true;
      };
      titlebarButtons.right = [
         "minimize"
         "maximize"
         "close"
      ];
    };

    panels = [
      {
        hiding = "none";
        lengthMode = "fill";
        location = "bottom";
        opacity = "opaque";
        screen = "all";

      }
    ];

    powerdevil = let
      battery = {
        autoSuspend.action = "hibernate";
        autoSuspend.idleTimeout  = 300;
        dimDisplay = {
          enable = true;
          idleTimeout = 20;
        };
        dimKeyboard.enable = false;
        displayBrightness = 100;
        keyboardBrightness = 100;
        inhibitLidActionWhenExternalMonitorConnected = false;
        powerButtonAction = "hibernate";
        powerProfile = "powerSaving";
        turnOffDisplay.idleTimeout = 60;
        whenLaptopLidClosed = "hibernate";
        whenSleepingEnter = "standbyThenHibernate";
      };
    in {
      inherit battery;
      lowBattery = battery // {
        displayBrightness = 0;
      };

      AC = {
        autoSuspend = {
          action = "sleep";
          idleTimeout = 600;
        };
        dimDisplay.enable = false;
        dimKeyboard.enable = false;
        displayBrightness = 100;
        keyboardBrightness = 100;
        inhibitLidActionWhenExternalMonitorConnected = true;
        powerButtonAction = "sleep";
        powerProfile = "performance";
        turnOffDisplay = {
          idleTimeout = 600;
          idleTimeoutWhenLocked = 20;
        };
        whenLaptopLidClosed = "sleep";
        whenSleepingEnter = "standbyThenHibernate";
      };

      batteryLevels = {
        criticalAction = "hibernate";
        criticalLevel = 5;
        lowLevel = 15;
      };
      general.pausePlayersOnSuspend = true;
    };


    session = {
      general.askForConfirmationOnLogout = true;
      sessionRestore.restoreOpenApplicationsOnLogin = "startWithEmptySession";
    };
    shortcuts = {
      "org.kde.powerdevil" = {
        "Decrease Keyboard Brightness" = "Shift+Volume Down";
        "Increase Keyboard Brightness" = "Shift+Volume Up";
        "Decrease Monitor Brightness" = "Ctrl+Volume Down";
        "Increase Monitor Brightness" = "Ctrl+Volume Up";
      };
      "mediacontrol" = {
        nextmedia = [ "Media Next" "Alt+Volume Up" ];
        previousmedia = [ "Media Previous" "Alt+Volume Down" ];
        playpausemedia = [ "Media Play" "Alt+Esc" ];
      };
      "kmix" = {
        increase_volume_small = "none";
        decrease_volume_small = "none";
      };
    };

    window-rules = [
      {
        description = "PIP for firefox";
        apply.layer = {
          value = "overlay";
        };
        apply.KeepAboveWindow = {
          value = true;
        };
        match.title.value = "Picture-in-Picture";
        match.window-class.value = "firefox";
      }
    ];
    windows.allowWindowsToRememberPositions = true;
    workspace = {
      enableMiddleClickPaste = false;
      clickItemTo = "select";
      cursor.theme = config.stylix.cursor.name;
      # iconTheme
    };
    configFile.kwinrc.Effect-overview.BorderActivate = 9;
    configFile.kded5rc."Module-gtkconfig"."autoload" = false;
    configFile."plasma-org.kde.plasma.desktop-appletsrc"."[Containments][30][Applets][35][Applets][47][Configuration][General]".volumeFeedback = false;
  };
}
