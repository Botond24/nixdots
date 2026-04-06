{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.nixcord.homeModules.nixcord
  ];

  programs.nixcord = {
    enable = true;
    user = "button"; # Needed for system-level config
    vesktop.enable = true;
    config = {
      plugins = {
        betterGifPicker.enable = true;
        betterUploadButton.enable = true;
        callTimer.enable = true;
        copyFileContents.enable = true;
        copyStickerLinks.enable = true;
        decor.enable = true;
        disableCallIdle.enable = true;
        expressionCloner.enable = true;
        fakeNitro.enable = true;
        fakeProfileThemes.enable = true;
        favoriteEmojiFirst.enable = true;
        favoriteGifSearch.enable = true;
        fixCodeblockGap.enable = true;
        fixImagesQuality.enable = true;
        fixSpotifyEmbeds.enable = true;
        fixYoutubeEmbeds.enable = true;
        gameActivityToggle.enable = true;
        gifPaste.enable = true;
        messageLinkEmbeds.enable = true;
        messageLogger.enable = true;
        openInApp.enable = true;
        shikiCodeblocks.enable = true;
        spotifyControls.enable = true;
        unlockedAvatarZoom.enable = true;
        USRBG.enable = true;
        youtubeAdblock.enable = true;
        platformIndicators.enable = true;
      };
    };
  };
}
