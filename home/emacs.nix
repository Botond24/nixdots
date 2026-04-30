{
  pkgs,
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
}
