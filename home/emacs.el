(require 'package)
(add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/") t)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("nongnu" . "https://elpa.nongnu.org/nongnu/") t)
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/"))
(package-initialize)

(setq custom-file "~/.emacs.d/custom.el")
(cua-mode 1)

(tool-bar-mode 1)
(menu-bar-mode 0)
(context-menu-mode 1)
(column-number-mode 1)
(tab-bar-mode 1)
(show-paren-mode 1)
(delete-selection-mode 1)

;;;sensible defaults
(setq inhibit-startup-message t)
(setq initial-scratch-message nil)
(setq gc-cons-threshold 20000000)
(setq max-lisp-eval-depth 10000)
(setq vc-follow-symlinks t)
(setq sentence-end-double-space nil)
(setq-default dired-listing-switches "-alh")
(fset 'yes-or-no-p 'y-or-n-p)
(global-auto-revert-mode 1)
(show-paren-mode t)
(setq show-paren-delay 0.0)
(setq visible-bell nil)
(defun comment-region-or-line ()
  (interactive)
  (let (beg end)
    (if (region-active-p)
        (setq beg (region-beginning) end (region-end))
      (setq beg (line-beginning-position) end (line-end-position)))
    (comment-or-uncomment-region beg end)))
(global-set-key (kbd "C-á") 'comment-region-or-line)
(global-unset-key (kbd "C--"))
(global-set-key (kbd "C-+") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-hl-line-mode)
(setq tramp-auto-save-directory "/tmp")
(setf make-backup-files nil)
(setf kill-buffer-delete-auto-save-files t)
(setq create-lockfiles nil)
(defun custom-isearch-forward ()
  (interactive)
  (if (region-active-p)
      (call-interactively 'isearch-forward-thing-at-point)
    (call-interactively 'isearch-forward-regexp)
    ))
(defun custom-isearch-backward ()
  (interactive)
  (if (region-active-p)
      (progn
       (call-interactively 'isearch-forward-thing-at-point)
       (isearch-repeat-backward))
    (call-interactively 'isearch-forward-regexp)
    ))

;;; custom keybinds
(global-set-key (kbd "C-é") (kbd "C-g"))
(global-set-key (kbd "C-q") 'save-buffers-kill-emacs)
(global-set-key (kbd "C-a") 'mark-whole-buffer)
(global-set-key (kbd "C-s") 'save-buffer)
(global-set-key (kbd "<mouse-9>") 'next-buffer)
(global-set-key (kbd "<mouse-8>") 'previous-buffer)

(global-set-key (kbd "C-f") 'custom-isearch-forward)
(define-key isearch-mode-map (kbd "C-f") 'isearch-repeat-forward)
(global-set-key (kbd "C-b") 'custom-isearch-backward)
(define-key isearch-mode-map (kbd "C-b") 'isearch-repeat-backward)

(define-key tab-bar-mode-map (kbd "C-t") 'tab-bar-new-tab)
(define-key tab-bar-mode-map (kbd "C-w") 'tab-bar-close-tab)

;;; packages
(require 'use-package-ensure)
(setq use-package-always-ensure t)
(setq use-package-always-defer t)
(setq load-prefer-newer t)
(setq byte-compile-warnings '(cl-functions))


;;; system clipboard
(use-package simpleclip)
(simpleclip-mode 1)
(define-key cua--region-keymap (kbd "C-S-c") nil)
(define-key cua--region-keymap (kbd "C-S-x") nil)
(define-key cua--region-keymap (kbd "C-S-v") nil)

(define-key simpleclip-mode-map (kbd "C-S-c") 'simpleclip-copy)
(define-key simpleclip-mode-map (kbd "C-S-x") 'simpleclip-cut)
(define-key simpleclip-mode-map (kbd "C-S-v") 'simpleclip-paste)

;;; redefine C-k for nano compat
(defun custom-kill-line ()
  (interactive)
  (if (use-region-p)
      (kill-region (region-beginning) (region-end))
    (kill-whole-line)))

(global-unset-key (kbd "C-k"))
(global-set-key (kbd "C-k") 'custom-kill-line)

;;; redo
(global-unset-key (kbd "C-y"))
(global-set-key (kbd "C-y") 'undo-redo)

;;; theme
(use-package gruber-darker-theme
  :init (load-theme 'gruber-darker t))

;;; treemacs

(use-package projectile
  :init
  (setq projectile-project-search-path '(("/run/media/button/SSD2TB/Documents/" . 3)))
  :config
  (projectile-register-project-type 'dlang '("dub.json" "dub.sdl")
                                  :project-file '("dub.json" "dub.sdl")
                                  :compile "dub build"
                                  :run "dub"
                                  :test "dub test"
				  :src-dir "source")
  (projectile-mode t)
  :bind
  (("C-p" . 'projectile-command-map))
  )

(use-package treemacs
  :defer t
  :commands (treemacs)
  :config
  (progn
    (setq
     treemacs-buffer-name-function            (defun empty-name (_) (format ""))
     treemacs-buffer-name-prefix              " *Treemacs-Buffer*"
     treemacs-width-is-initially-locked       t)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)
    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always)
    (when treemacs-python-executable
      (treemacs-git-commit-diff-mode t))

    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple)))

    (treemacs-hide-gitignored-files-mode nil)
    (add-hook 'treemacs-mode-hook (lambda() (display-line-numbers-mode -1))))

  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t d"   . treemacs-select-directory)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-f" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)
	:map treemacs-mode-map
        ("."         . treemacs-increase-width)
	(","         . treemacs-decrease-width))
  :hook
  (after-init . (lambda ()
		  (tool-bar-add-item "diropen" 'treemacs 'treemacs :help "Open project view...")))
  )


(use-package treemacs-tab-bar ;;treemacs-tab-bar if you use tab-bar-mode
  :after (treemacs)
  :config (treemacs-set-scope-type 'Tabs))

(use-package treemacs-icons-dired
  :hook (dired-mode . treemacs-icons-dired-enable-once))

(use-package treemacs-magit
  :after (treemacs magit))

(use-package treemacs-projectile
  :after (treemacs projectile))

;;; embark
(use-package marginalia
  :config
  (marginalia-mode))

(global-unset-key (kbd "C-x C-x")) ;;; unset which mark keybind
(use-package embark
  :bind
  (("C-x C-x" . embark-act)         ;; pick some comfortable binding
   ("M-." . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'
  :config
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none))))
  )



;;; ido-mode
(ido-mode 1)
(ido-everywhere 1)
(use-package smex)
(use-package ido-completing-read+)
(ido-ubiquitous-mode 1)

(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)


(defun whitespace-remove ()
  (interactive)
  (add-to-list 'write-file-functions 'delete-trailing-whitespace))

(add-hook 'c-mode-hook 'whitespace-remove)
(add-hook 'c++-mode-hook 'whitespace-remove)
(add-hook 'emacs-lisp-mode-hook 'whitespace-remove)
(add-hook 'python-mode-hook 'whitespace-remove)

;;; magit
(use-package magit)

(setq magit-auto-revert-mode nil)
(global-unset-key (kbd "C-x m")) ; unset new mail keybind
(global-set-key (kbd "C-x m s") 'magit-status)
(global-set-key (kbd "C-x m l") 'magit-log)

;;; multiple-cursors
(use-package multiple-cursors)
(global-unset-key (kbd "M-<down-mouse-1>"))
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C-M-<down>")  'mc/mark-next-like-this)
(global-set-key (kbd "C-M-<up>")    'mc/mark-previous-like-this)
(global-set-key (kbd "C-x C-,")     'mc/mark-all-like-this)
(global-set-key (kbd "C-\"")        'mc/skip-to-next-like-this)
(global-set-key (kbd "C-:")         'mc/skip-to-previous-like-this)
(global-set-key (kbd "M-<mouse-1>") 'mc/add-cursor-on-click)

;;; dired
(require 'dired-x)
(setq dired-omit-files
      (concat dired-omit-files "\\|^\\..+$"))
(setq-default dired-dwim-target t)
(setq dired-listing-switches "-alh")
(setq dired-mouse-drag-files t)

;;; company (complete anything)
(use-package company
  :hook (after-init . global-company-mode))
(use-package company-box
  :hook (company-mode . company-box-mode))


;;; c-mode
(use-package company-c-headers
  :after company
  :config (add-to-list 'company-backends 'company-c-headers))

(use-package c-eldoc)
(add-hook 'c-mode-hook 'c-turn-on-eldoc-mode)
(add-hook 'c++-mode-hook 'c-turn-on-eldoc-mode)
(defvar c-eldoc-includes "-I./ -I../ ") ;; include flags

;;; move text
(use-package move-text)
(global-set-key (kbd "M-<up>") 'move-text-up)
(global-set-key (kbd "M-<down>") 'move-text-down)

;;; compile mode
(require 'compile)
(add-to-list 'compilation-error-regexp-alist
             '("\\([a-zA-Z0-9\\.]+\\)(\\([0-9]+\\)\\(,\\([0-9]+\\)\\)?) \\(Warning:\\)?"
               1 2 (4) (5)))
(require 'ansi-color)
(defun colorize-compilation-buffer ()
  (ansi-color-apply-on-region compilation-filter-start (point-max)))
(add-hook 'compilation-filter-hook 'colorize-compilation-buffer)

;;; lsp mode
(use-package lsp-mode)
(use-package lsp-ui
  :after lsp-mode)

;;; go mode
(use-package go-mode
  :mode "\\.go\\'")
(add-hook 'go-mode-hook 'lsp-deferred)
(defun lsp-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'go-mode-hook 'lsp-install-save-hooks)

;;; gdb
(setq gdb-show-main t)
(setq gdb-many-windows t)

;;; d-mode
(use-package d-mode)
(add-to-list 'auto-mode-alist '("\\.d[i]?\\'" . d-mode))

;;; ffap
(define-key cua-global-keymap (kbd "C-<return>") nil)
(global-set-key (kbd "C-<return>") 'ffap)
(global-set-key (kbd "C-<down-mouse-1>") 'ffap-at-mouse)

;;; shell
(eval-after-load 'comint
  '(progn
     (define-key comint-mode-map (kbd "M-<up>") 'comint-previous-input)
     (define-key comint-mode-map (kbd "M-<down>") 'comint-next-input)))

;;; PIO
(use-package platformio-mode
  :hook
  (c++-mode . platformio-conditionally-enable))

;;; nix
(use-package nix-mode
  :mode "\\.nix\\'")
(add-hook 'nix-mode-hook 'lsp-deferred)
(add-hook 'nix-mode-hook 'lsp-install-save-hooks)

;;; auto parentheses
(electric-pair-mode t)

;;; discord
(use-package elcord
  :config
  (elcord-mode))

;;; treesitter
(use-package treesit-auto
  :config
  (global-treesit-auto-mode))

;;; kdl (niri)
(use-package kdl-mode
  :after (treesit-auto))

;;; lua
(use-package lua-mode
  :mode "\\.lua\\'")
(add-hook 'lua-mode-hook 'lsp-deferred)
(add-hook 'lua-mode-hook 'lsp-install-save-hooks)


(load-file custom-file)
