{
  pkgs,
  config,
  ...
}:
{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
    extraPackages =
      epkgs: with epkgs; [
        nix-mode
        nixfmt
        nushell-mode
        platformio-mode
        smex
        multiple-cursors
        company
        c-eldoc
        markdown-mode
        lsp-mode
        go-mode
        d-mode
        pkgs.emacs-all-the-icons-fonts
        smartparens
        kdl-mode
        tree-sitter
        pkgs.gcc
        pkgs.w3m
      ];
  };
  home.file.".emacs.d/init.el".source = ./emacs.el;
  home.file.".emacs.d/custom.el".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nixos/home/custom.el";
}
