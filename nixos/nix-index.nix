{
  inputs,
  ...
}: {
  imports = [
    inputs.nix-index.nixosModules.default
  ];

  programs.nix-index-database = {
    enable = true;
    comma.enable = true;
  };
}
