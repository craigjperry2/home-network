# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz home-manager
      # sudo nix-channel --update
      <home-manager/nixos>
    ];

  # sudo bootctl install
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 15;

  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.kernelParams = [ "quiet" "udev.log_level=0" ];
  boot.consoleLogLevel = 0;

  boot.initrd.verbose = false;
  boot.initrd = {
    luks.devices = {
      luksCrypted = {
        device = "/dev/nvme0n1p2";
        preLVM = true;
        allowDiscards = true;
      };
    };
  };

  boot.plymouth.enable = true;
  boot.plymouth.theme = "bgrt";

  networking.hostName = "r3";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/London";

  i18n.defaultLocale = "en_GB.UTF-8";

  console.useXkbConfig = true;

  services.xserver.enable = true;  # NB: this doesn't choose Xorg vs Wayland
  services.xserver.xkb = {
    layout = "gb";
    # variant = "colemak_dh";
    # options = "caps:escape, compose:ralt, terminate:ctrl_alt_bksp";
    # options = "misc:extend,lv5:caps_switch_lock,compose:menu";
  };

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "craig";

  programs.hyprland.enable = true;

  # https://nixos.wiki/wiki/Wayland#Electron_and_Chromium
  environment.sessionVariables.NIX_OZONE_WL = "1";
  environment.sessionVariables.ELECTRON_OZONE_PLATFORM_HINT = "auto";

  environment.shells = with pkgs; [ zsh ];

  users.users.craig = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    initialPassword = "changeme01";
    shell = pkgs.zsh;

    # :r!curl -s https://github.com/craigjperry2.keys
    # :'<,'>s/(.*)/      "\1"/
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDM9Rft+Op+5VDFBR989z/iY4pr/fVpAbzNmHM3b8badQwDKukcCbYwMWtke4d0/AxeBcK+uoTJHN7ebQewKqm/N7fGpEOrNRBjRLLiOnN6wpUeO06LbEido+lnt3Pf9MHW1W3sorxfpl97CtRuLYtpyBR5i+FowZssyKqAGOntXldEkBB+oK4hQbmVArt76JOIWwNueO9TY3qQGFlKm24qP2JVQN2zFW3pCWJgfeTUITAsEFDg7xhDKWEwN0srf70slc06QvBon4D4afgovkcdFb4vvgw4ucx+6+BnydzLxFa0iEx69aFOnhuMAItFRFxyfRicJYBms2pCUE5Q3lmakr8e6cVz/dxi6a9PDFBkW/n53QhTgzIoKy1z/45ofolzkaeCozMgre/SJNONXHBJwX5yuZjWxkYU0EAOfEDtzBYFVowHMg8UJ3I8QJIiC+cAolmEFhZiAR3nvFEipRqBIZ+EEht53YZdh2cZVyS8r0haq15lDFAGDzFY2w0qO8k="
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDWTevJ63ZnTe1ftAB8bUp9oUhPnWsEaMxZnNkw6BpOukFfnwVT9/QcMSXRtY5z1SBfmeIPS/x+Co5BM1rkQlnQ7iETlX68rQUjaCW/f1761hWxvvsG5uWvgarcZWKJorEL5wXSxe41l0IWzzNQaBReNZvN/QCQVDUTQaB5jXGO2rrIa7B4M+rL+oMDQYKVdN66xLKRn6vu0lSkPaTeecTsakQ0XNEnFieYNTyQRh9SAvW4IVZLQnLqZx8Q1MskFE7+uZ0qP5IZdTJWVhSF2j+LRkruOs0dV73JGXNpopunoqHSC+9cg6nS+etRiTnhweRlsvjHSftlsYTxXXnlAuRFSZ+WWIx/KbSbBGnXbJVGitAJVHb1wA4D6f2f2Iw6ngnhJRKZ63tZGqJUJj2v8kDbOp4BAZnGTS6bnqVuGL0Of6AfHbPm5bWn+x6B5NDvgwhbBrYmQn+UQFvP3Y+YZj7qbHohrBVzICNMJSKRDOs2w4DNM/4BZepqlzicX85gedk="
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCrgbUtLWqld9mHi+mcS/3hhNgrnlEjgOrBL9FfOfZuIjbOtTLQ7WaNycYfPPXUmnKzkPKRWOHg/zdltwjY5Nx/UULxioqhZiQ5XOno6l6x2daUEQP3ZTvnO6XYzrewBMZV6KtwIkUObqfRGIovB+XguW4z1JWvrkh1Q7sUTRxbbVidWBb40XG6IlFSmef6n908KaEbGQcOBDvwtRNWD5QoNv+SEI7G8iP/GT7VL/5q84yOOIcXcICG0PgXWcKpC+BAK5Z/1//+ifrWbavQiZTDyvDKjqDKajsCerAR4ZG2qOYeXTm80PKhJSqOUKwUsdxfDlkQKFI7wg041t1IQzfdx0784/172yG6eo0wyTF27g8QMrNwXbsYuYTSY+1LaoDu1fs0sGbmmWS3Qr9ZWc96736uXf6WyNiQeYLWCQDga4uAyvEuIXweOwBSx/B9erefjcNIYo1e85reaxWCgEKwIn0Bjxy+SmVQIkhhUv2k1EezcnXma5RZPeoEb2Jng8E="
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDRn7uRtz/cItl2cizdD+Rqre53R7CC7yqypaXxnqdtqhY1nyVX+4RrVbqoeV+8IoNU9WEngWOGHFSDBW4Sp3xOEvj678i7tzo1OhkDZi/PLrpnQpzopgiERE9aVwD4XTM9NbhX1ODzyy9Nae+rcsS47XmzrNlWc6yuWNMy4kvqfOp4EefYiVz8IQKiwi3vAIxjfhZtbTLkjNd8K7KgbFg3lROaC3ckjgbJn+RPLH2vy1nYOGulsyFwEEJGpd5Ar2clV7/8OcCOHEwXj+ouNCPrtrmQthpwu/D6+U78x//s3xHlCq3GorrfcoIOCfqMh62uDK/vSvn064ofi4hliQGjloZuTRTLJHxiFX0RBhKp9zHnAR/EkHgI06vcWKqLY4LGC7txvhlD371fiPtUdblR8ppy4DKXNrE/uuGEHiIffrb5KthNMlmq4C+2FBaueD31gIo3rn0p2P92MH6BiVPUC93wsxZulvua0nArHSNwXA5WcPjv43sdjrb+nJSxIhk="
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDP5IxeTEUGKHCGIUrzcMuEYhbc6V6PaGfuCRclxDhtxl8A3SqFunuhcSxORTh4yXIA1/guEQa41KMnzQoXT/WtuKbEezHKv1cjCUueF2IG21OEak59ipizYwiG32RRM79dlb40TzTK0g/TT9ocoN9SSB33hUtdi18/tnGEo54+2ev+frQ05t1eL7uKuJv5M4wdLIxiPdDeo2LvZNTZhTWJbivP2JvV/KmbFxs7UcyJLdRoO6l03WV/vG48N+nLPFZM3d06Vg9UKrl/f00aGsJhcSPRjf3xXb1qGmO5qK7aY6obdhc5NmCGruAYbKMuKnw5oP3zldN4p46cNzNcMwzsQ9IyvNxRCfgjSN1kehqQA/DAuzJn92UW0KkiBmgU3bg4vdAMFBAvYkLzrvmZKOOUJs8GwZeLuAtR0lPtgFKQQe0/LmZEJAckHDEudbFqZP0/dreQtauVIJeoJH7gCBmVJIJQ7wNRIw1BXn3NVfPJlz3j6u4oUZwPDnnE5RAzcTmCunCIWFtgG5k6EpUxDcsg5T/B/3ieUBsZgdUrroGAMMI7cHsl7wlCi8I2svTGL6L7G2QSTp1YWWSaP+8QCOWE5jEcBOKww1NZZ0Mm5RGQBTw71QqO37ULCJtwTWYfusF94BQTB+nJKKhEFD6gAuCFevwiATikBzreo3nCETC3rw=="
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC2Iv4jKFbwqfKoMc+5833F8NkFH5oiyYFqyLE/DCwXDe14rxLscoMFhcE9DD/nicVx1WEipz+3SU8/XV4vf76FE9Hk68bklSx/6AGol5um8pJ4E9HorH+VZ7H289oMQY05Vog2g14qtrNubJ5xCbBrfQhbYjVWEUnOiOrEMQNjDi6hrPpP6og4Ed/T06H8MhuPeYjg44c5L7P7S1w5zmK6Oc9+UH4Xihl6djpW921KcHFfjJoTISjFZATQT7yyIZ5ZigL+wb8lrS0Il+FKtupspzBWqbeTMAo4/8FSWAnMPkmWF7vhJK8ku3tZDZ1brHs6yt83ZRoBqy6mA8xEFRlqPvOKNe2bH8a7Jpnqiqr8Vk3/3veaK5vBUvV0iuFdvhr1Ns8XjUVhqK815LsR0UFni0R1CTZf34lypZyFVmmbwtiFxIBCcmR1jMMDeJh0o4EcWu/RjyvEfafLxcHyyKfEhZOytfiBqCUMOw2Gxx3G243NcnP3czRwhtOoHcr/Gos="
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCvrVYKEtdgry5/mIRhn0TBsq/VdyqBcWumyRkwtQFWmseIWqbC7HQDx62Lsg21N2ZouRT+1ZFBufkf8SAXIbJb+61qj9Anne1DiqmQZesCQiMjE5zrMpGSorP+U0D49+wLi2tLAhI5sbAqY0AL94Y017TlAviwYRwk4Ue9vDJUSC/KOcbsw61DQvIfXsc08DIW6zdUs71cbA6Fh8U5tgU4h6Uat729mMCdmRBRAMCEALnfZxAQY/GaTi9kIXBUdUfw1VV0gD/W0K8ihmNfBERwbeEZ2/vmsPCVnBC8TRt4eLigc2Aq3LN+NmCBL5Awaz5ZRG7CYWCZ5Q1X4zTQQZK9"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCviDNchUaNKYlUjVWUSlwDoI1xrwYl19IrHwTZsKZ8nQUMZJ0qvLI8XGv3jQ1JV6giZaoTU9aBPOS6gektOHWlTBheubW/rrq+OWYQSS3F9LOx12JOI6VHJAtKdBAzKx99RQD7IE0QNQ30alh5yrcO8uy/NnsRsANl3Oa2YPmoAlT3BxjYmkec/Nu20JLxb+/iOVJWKAO5OZ9xdvRPfDvnciX18vFxUK+7/ydE8NTrgtS908S2dXukTPXTHfGIvJjW4hnMurIyNyBEzzJ3wnH1ZWnqJ6pc+NnXR8wwWoc6uCswUafll0c9bEkwuXAPoaDjFBM9cBfedV1Z2dYUzlYsewn6KGMwaLsJ5gPR7y7b2aHICAJxkSrOoqXei4q8/BAbhqgUS52wjzl1QsMcCSY2H5/mj7QvU5oaR0LTt0VyPE26Y/9L7lXm8kRxKMf3Erq7gY7HWMG/PhZK0pDT999HbG3OHvwOoUQRyyh6eVs7zAZJ9D6lnIJFvYeDvoZPLa8="
    ];

    # NB: see home-manager section instead
    #   packages = with pkgs; [
    #     firefox
    #     tree
    #   ];
  };

  home-manager.useGlobalPkgs = true;
  home-manager.users.craig = { pkgs, ... }: {
    home.packages = with pkgs; [
      bat
      bun
      curl
      duckdb
      dust
      eza
      fd
      gh
      go
      jq
      p7zip
      python312
      racket
      ripgrep
      sqlite
      unzip
      vscode.fhs
      wget
      xsv
      zip
    ];
    home.sessionVariables = {
      BAT_THEME = "Solarized (dark)";
    };
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "fd --type f";
    };
    programs.nnn = {
      enable = true;
      package = pkgs.nnn.override ({ withNerdIcons = true; });
      bookmarks = {
        l = "~/Code/local";
	r = "~/Code/github.com";
	d = "~/Code/github.com";
      };
    };
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      plugins = with pkgs.vimPlugins; [
        vim-nix
        vim-surround
	vim-unimpaired
	vim-sneak
	fzfWrapper
	fzf-vim
        {
	  plugin = nnn-vim;
          config = ''
            let g:nnn#layout = {'window': {'width':0.9, 'height':0.6, 'highlight':'Debug'}}
            let g:nnn#action = {'<c-x>': 'split', '<c-v>': 'vsplit'}
	  '';
        }
        {
	  plugin = vim-colors-solarized;
          config = ''
            colorscheme solarized
	  '';
        }
        {
	  plugin = lualine-nvim;
          config = ''
            lua << END
            require('lualine').setup({options={theme='solarized_dark'}})
END
	  '';
        }
	nvim-web-devicons
      ];
      extraConfig = ''
        autocmd!
        set nocompatible
        set number
        syntax enable
        set encoding=utf-8
        scriptencoding utf-8
        set fileencodings=utf-8,latin
        set nobackup
        set nohlsearch
        set showcmd
        set scrolloff=5
        set expandtab
        
        set inccommand=split
        
        " Don't redraw while executing macros
        set lazyredraw
        
        set smarttab
        filetype plugin indent on
        set tabstop=2
        set shiftwidth=2
        set ai
        set si
        set nowrap
        set backspace=start,eol,indent
        
        " Finding files - Search down into subfolders
        set path+=**
        set wildignore+=*/node_modules/*
        
        " Turn off paste mode when leaving insert
        autocmd InsertLeave * set nopaste
        
        " Toggle paste mode
        nnoremap <F2> :set invpaste paste?<CR>
        set pastetoggle=<F2>
        
        " Add asterisks in block comments
        set formatoptions+=r
        
        let mapleader=" "
        
        set cursorline
        
        " Restore last cursor position on re-opening a file & scroll to middle of screen
        autocmd BufReadPost *
          \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
          \ |   exe "normal! g`\""
          \ |   exe "normal! zz"
          \ | endif
        
        " JavaScript
        au BufNewFile,BufRead *.es6 setf javascript
        
        " TypeScript
        au BufNewFile,BufRead *.tsx setf typescriptreact
                
        " Markdown
        au BufNewFile,BufRead *.md set filetype=markdown
        au BufNewFile,BufRead *.mdx set filetype=markdown
        
        set suffixesadd=.js,.es,.jsx,.json,.css,.less,.sass,.styl,.py,.md
        autocmd FileType yaml setlocal shiftwidth=2 tabstop=2

        " fzf plugin
	nnoremap <leader>zr :Rg 
        nnoremap <leader>zl :Lines<CR>
        nnoremap <leader>zm :Marks<CR>
        nnoremap <leader>zf :Files<CR>
        nnoremap <leader>zb :Buffers<CR>
        nnoremap <leader>zg :GFiles<CR>
        nnoremap <leader>zt :Tags<CR>
        nnoremap <leader>zh :History:<CR>
        nnoremap <leader>z/ :History/<CR>
        
        " Splits, used with C-w H/K to rearrange them
        set splitright
        set splitbelow
        nnoremap <leader>- :new<CR>
        nnoremap <leader>\| :vnew<CR>
        
        " Navigate windows
        " map sh <C-w>h
        " map sk <C-w>k
        " map sj <C-w>j
        " map sl <C-w>l
        " map sd <C-w>q
        
        " Resize windows
        nmap <C-S-left> <C-w><
        nmap <C-S-right> <C-w>>
        nmap <C-S-up> <C-w>+
        nmap <C-S-down> <C-w>-
        
        " Buffer management
        nnoremap <leader>bl :ls<CR>:buffer<Space>
        nnoremap <leader>bj :bj<CR>
        nnoremap <leader>bk :bk<CR>
        nnoremap <leader>bd :bd<CR>
        
        nmap te :tabedit 
        nmap <S-Tab> :tabprev<Return>
        nmap <Tab> :tabnext<Return>
         
        " Map Y like D, C etc. behave (to end of line)
        nnoremap Y  y$
        
        " Save with root permission
        command! W w !sudo tee > /dev/null %
                
        " Move lines up or down
        nnoremap <A-j> :m .+1<CR>==
        nnoremap <A-k> :m .-2<CR>==
        inoremap <A-j> <Esc>:m .+1<CR>==gi
        inoremap <A-k> <Esc>:m .-2<CR>==gi
        vnoremap <A-j> :m '>+1<CR>gv=gv
        vnoremap <A-k> :m '<-2<CR>gv=gv
      '';
    };
    programs.zsh = {
      enable = true;
      history.share = false;
      plugins = [   
        {                                                                                   
          name = "powerlevel10k";                                                           
          src = pkgs.zsh-powerlevel10k;                                                     
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";                         
        }
      ];
      # Exit first run with 'n' to save generated config at ~/.p10k.zsh
      initExtraFirst = "source ~/.p10k.zsh";
      initExtra = ''
        # vi mode keybindings
        bindkey -v
        
        # Emacs/readline & vi style history searching
        #bindkey ^R history-incremental-search-backward
        bindkey -M vicmd '?' history-incremental-search-backward
        bindkey -M vicmd '/' history-incremental-search-forward
        
        # Beginning search with arrow keys
        autoload -U up-line-or-beginning-search
        zle -N down-line-or-beginning-search
        autoload -U down-line-or-beginning-search
        zle -N up-line-or-beginning-search
        bindkey "^[[A" up-line-or-beginning-search
        bindkey "^[[B" down-line-or-beginning-search
        bindkey -M vicmd "k" up-line-or-beginning-search
        bindkey -M vicmd "j" down-line-or-beginning-search
        
        # Years ago i started using ctrl+A / ctrl+x in vi, this is frequently useful
        autoload -U incarg
        zle -N incarg
        bindkey -M viins '^A' incarg
        bindkey -M vicmd '^A' incarg
        decarg() {
          local incarg=-1
          incarg
        }
        zle -N decarg
        bindkey -M viins '^X' decarg
        bindkey -M vicmd '^X' decarg
        
        # When v mode isn't enough, edit cmdline in vim
	autoload -Uz edit-command-line
	zle -N edit-command-line
        bindkey -M vicmd "^V" edit-command-line
        
        # Pause 10ms (minimum) before entering cmd mode
        export KEYTIMEOUT=1
        
        # Escape takes wayyyy too long to process in some terminals, ctrl+[ is a chord and i'm a vim user, so...
        bindkey -M viins 'jk' vi-cmd-mode

	# nnn integration
	n ()
        {
            if [ -n $NNNLVL ] && [ "''${NNNLVL:-0}" -ge 1 ]; then
                echo "nnn is already running"
                return
            fi
         
            NNN_TMPFILE="''${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
         
            # Unmask ^Q (, ^V etc.) (if required, see `stty -a`) to Quit nnn
            # stty start undef
            # stty stop undef
            # stty lwrap undef
            # stty lnext undef
         
            nnn -c "$@"
         
            if [ -f "$NNN_TMPFILE" ]; then
                    . "$NNN_TMPFILE"
                    rm -f "$NNN_TMPFILE" > /dev/null
            fi
        }
      '';
      shellAliases = {
        cat = "bat";

        gd = "git d";
        gds = "git ds";
        gl = "git l";
        gs = "git s";
        gpl = "git pl";
        gps = "git ps";

        ls = "eza";
        l = "eza --git --grid --across --icons -l --header";
	ll = "eza --git -l --colour=always --tree --level=2 --sort time --icons --header";

        mkdir = "mkdir -p";
      };
    };
    programs.emacs = {
      enable = true;
      extraConfig = ''
        ;;;; Better defaults for Emacs to help get new users up and running quickly.
        ;;;; This configuration is meant to help solve some common usability problems,
        ;;;; particularly with Emacs's default completion framework, cluttered UI,
        ;;;; and package installation. Inspired by the Better Defaults repo:
        ;;;; https://git.sr.ht/~technomancy/better-defaults.
        ;;;;
        ;;;; Annotations are included for various options, but I recommend using
        ;;;; the built-in Emacs help to learn more about each configuration setting.
        ;;;; For example, `C-h v` or `M-x describe-variable`.
        
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
        
        ;; On OSX swap meta and super for better keyboard ergonomics. This is
        ;; great if you use a Windows-style keyboard on Mac OS.
        (defmacro if-osx (&rest body)
          `(if (eq system-type 'darwin)
               (progn ,@body)))
        
        (if-osx
         (setq mac-command-modifier 'meta)
         (setq mac-option-modifier 'super))
         
        ;; Unique buffer names for matching files, very useful when dealing
        ;; with lots of index.ts, for example
        (require 'uniquify)
        
        ;; Misc. settings
        ;; Use `C-h v` to read the docs on the individual options
        (electric-pair-mode t)
        (show-paren-mode 1)
        (setq-default indent-tabs-mode nil)
        (save-place-mode t)
        (savehist-mode t)
        (recentf-mode t)
        (global-auto-revert-mode t)
        
        ;; Display line numbers when in programming modes
        (add-hook 'prog-mode-hook 'display-line-numbers-mode)
        
        (setq uniquify-buffer-name-style 'forward
              window-resize-pixelwise t
              frame-resize-pixelwise t
              load-prefer-newer t
              backup-by-copying t
              custom-file (expand-file-name "custom.el" user-emacs-directory))
        
        ;; (unless package-archive-contents
        ;;   (package-refresh-contents))

	(eval-when-compile
	  (require 'use-package))
        
        ;; Great looking theme
        (use-package modus-themes
          :ensure t
          :init
          (modus-themes-load-themes)
          :config
          (modus-themes-load-vivendi))
        
        ;; Code-completion at point
        (use-package company
          :ensure t
          :hook (after-init . global-company-mode)
          :custom
          (company-idle-delay 0))
          
        ;; Better minibuffer completions and project searching
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
        
        ;; Use emacsclient to open files in an already-running Emacs process
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
    programs.git = {
      enable = true;
      userName = "Craig Perry";
      userEmail = "craigp84@gmail.com";
      aliases = {
        a = "!git status --short | fzf -m | awk '{print $2}' | xargs git add";
        ac = "!f(){ git add --all . ; git commit --all --message=\"$1\"; };f";
        b = "!git branch -q -a --color=always | sed -e 's/^..//' -e '/->/d' | fzf --ansi --preview-window right:75% --preview 'git log -n $(( $( tput lines ) - 3 )) --color=always --pretty=reference {}' | xargs git switch";
        cm = "commit --message";
        d = "diff --ignore-all-space";
        ds = "diff --staged --ignore-all-space";
        l = "log --topo-order --first-parent --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'";
        la = "log --all --topo-order --first-parent --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'";
        lg = "log --all --oneline --graph --decorate";
        ps = "!git push origin $(git symbolic-ref --short HEAD)";
        pl = "!git pull origin $(git symbolic-ref --short HEAD)";
        s = "status --short --branch";
        w = "whatchanged";
        ctop = "!git log | grep Author | sort | uniq -c | sort -rn";
        ltop = "!git ls-files | xargs -n1 git blame --line-porcelain HEAD | grep '^author ' | sort | uniq -c | sort -nr";
        find = "!f() { git log --pretty=format:\"%h %cd [%cn] %s%d\" --date=relative -S'pretty' -S\"$@\" | fzf -m | awk '{print $1}' | xargs -I {} git diff {}^ {}; }; f";
        # edit conflicted file on merge
        edit-unmerged = "!f() { git ls-files --unmerged | cut -f2 | sort -u ; }; vim `f`";
        # add conflicted file on merge
        add-unmerged = "!f() { git ls-files --unmerged | cut -f2 | sort -u ; }; git add `f`";
      };
      extraConfig = {
	color.ui = "auto";
	core.editor = "code --wait";
	diff.tool = "vscode";
	difftool."vscode".cmd = "code --wait --diff \"$LOCAL\" \"$REMOTE\"";
        init.defaultBranch = "main";
	merge.tool = "vscode";
	mergetool."vscode".cmd = "code --wait \"$MERGED\"";
	pull.ff = "only";
      };
    };
    programs.kitty = {
      enable = true;
      font = {
        name = "JetBrainsMonoNL Nerd Font Mono";
        size = 12;
      };
      theme = "Solarized Dark";
    };

    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = "24.05";
  };

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    brightnessctl
    # Download tarball from citrix, 24.2.0.64.tar.gz
    # then: nix-prefetch-url file://$PWD/linuxx64-22.12.0.12.tar.gz
    # then: add to configuration.nix and switch
    # then: wfica <launch.ica> file
    citrix_workspace
    docker-compose
    dolphin
    dunst
    firefox
    fuzzel
    killall
    kitty 
    networkmanagerapplet
    pavucontrol
    waybar
    zsh
  ];

  programs.zsh.enable = true;

  fonts.packages = with pkgs; [
    font-awesome
    noto-fonts
    noto-fonts-emoji
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  virtualisation.docker.enable = true;
  virtualisation.docker.daemon.settings.data-root = "/var/lib/docker";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Enable touchpad support
  services.libinput.enable = true;

  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?

}

