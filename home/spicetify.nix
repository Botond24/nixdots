{
inputs,
pkgs,
...
}: {
  imports = [
    inputs.spicetify-nix.homeManagerModules.default
  ];
  programs.spicetify =
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      enable = true;

      enabledExtensions = with spicePkgs.extensions; [
        adblock
        hidePodcasts
        shuffle # shuffle+ (special characters are sanitized out of extension names)
        playNext
        fullAppDisplay
      ];
      enabledCustomApps = with spicePkgs.apps; [
        lyricsPlus
        ncsVisualizer
        #({
        #  src = pkgs.fetchzip {
        #    url ="https://github.com/harbassan/spicetify-apps/releases/download/stats-v1.1.3/spicetify-stats.release.zip";
        #    sha256 = "8CO5M0EM0n/aXD79Xsis0eiBpxj2zVLfu49/kbO+m+M=";
        #  };
        #  name = "stats";
        #})
      ];
      enabledSnippets = with spicePkgs.snippets; [
        rotatingCoverart
        pointer
      ];

      theme = spicePkgs.themes.dribbblish;
      colorScheme = "lunar";
    };
}
