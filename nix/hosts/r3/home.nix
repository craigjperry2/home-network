{ config, pkgs, inputs, ... }:

{
  imports = [
    ../../modules/home/core.nix
  ];

  home.username = "craig";
  home.homeDirectory = "/home/craig";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    curl
    go
    p7zip
    python312
    racket
    unzip
    vscode.fhs
    xan
    zip
  ];

  programs.emacs = {
    enable = true;
    extraConfig = ''
      ;; Performance tweaking
      (setq gc-cons-threshold 100000000) ; 100 mb
      (setq read-process-output-max (* 1024 1024)) ; 1mb
      
      ;; Remove UI clutter
      (menu-bar-mode -1)
      (tool-bar-mode -1)
      (scroll-bar-mode -1)
      (setq inhibit-startup-screen t)
      
      ;; Set your font preferences here
      (set-face-attribute 'default nil :height 120)
      
      (defmacro if-osx (&rest body)
        `(if (eq system-type 'darwin)
             (progn ,@body)))
      
      (if-osx
       (setq mac-command-modifier 'meta)
       (setq mac-option-modifier 'super))
       
      (require 'uniquify)
      
      (electric-pair-mode t)
      (show-paren-mode 1)
      (setq-default indent-tabs-mode nil)
      (save-place-mode t)
      (savehist-mode t)
      (recentf-mode t)
      (global-auto-revert-mode t)
      
      (add-hook 'prog-mode-hook 'display-line-numbers-mode)
      
      (setq uniquify-buffer-name-style 'forward
            window-resize-pixelwise t
            frame-resize-pixelwise t
            load-prefer-newer t
            backup-by-copying t
            custom-file (expand-file-name "custom.el" user-emacs-directory))
      
      (eval-when-compile
        (require 'use-package))
      
      (use-package modus-themes
        :ensure t
        :init
        (modus-themes-load-themes)
        :config
        (modus-themes-load-vivendi))
      
      (use-package company
        :ensure t
        :hook (after-init . global-company-mode)
        :custom
        (company-idle-delay 0))
        
      (use-package vertico
        :ensure t
        :custom
        (vertico-cycle t)
        (read-buffer-completion-ignore-case t)
        (read-file-name-completion-ignore-case t)
        (completion-styles '(basic substring partial-completion flex))
        :init
        (vertico-mode))
      
      (use-package savehist
        :init
        (savehist-mode))
      
      (use-package marginalia
        :after vertico
        :ensure t
        :init
        (marginalia-mode))
      
      (require 'server)
      (unless (server-running-p) (server-start))
    '';
    extraPackages = epkgs: with epkgs; [
      company
      marginalia
      modus-themes
      use-package
      vertico
    ];
  };

  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMonoNL Nerd Font Mono";
      size = 12;
    };
    themeFile = "Solarized_Dark";
  };

  programs.zsh.shellAliases = {
    sns = "( cd ~/Code/github.com/craigjperry2/home-network/nix ; sudo nixos-rebuild switch --flake .#r3 )";
    uu = "( cd ~/Code/github.com/craigjperry2/home-network/nix ; nix flake update ); sns";
  };
}
