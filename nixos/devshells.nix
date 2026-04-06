{
pkgs,
inputs,
...
} : {
  default = pkgs.mkShell {
    packages = with pkgs; [
        nil
    ];
    shellHook = ''
      exec nu
    '';
  };
}
