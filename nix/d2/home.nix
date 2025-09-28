{ config, pkgs, inputs, ... }:

{
  # Basic user info
  home.username = "craig";
  home.homeDirectory = "/Users/craig";
  home.stateVersion = "25.05";

  # User packages (separate from system packages)
  home.packages = with pkgs; [
    bat
    bun
    delta
    duckdb
    dust
    eza
    fd
    ffmpeg
    flac
    gh
    iperf3
    jq
    kubectl
    lazygit
    libwebp
    nmap
    nodejs
    opencode
    procs
    python3
    ripgrep
    sqlite
    tokei
    uv
    wget
    yt-dlp
    zellij
  ];

  home.sessionVariables = {
    BAT_THEME = "Solarized (dark)";
    EZA_COLORS = "xx=0";
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f";
  };

  # Git configuration
  programs.git = {
    enable = true;
    userName = "Craig Perry";
    userEmail = "craigp84@gmail.com";
    extraConfig = {
      color.ui = "auto";
      core.pager = "delta";
      delta.navigate = true;  # use n and N to move between diff sections
      delta.line-numbers = true;
      delta.side-by-side = true;
      delta.hyperlinks = true;
      delta.syntax-theme = "Solarized (dark)";
      init.defaultBranch = "main";
      interactive.diffFilter = "delta --color-only";
      merge.conflictstyle = "zdiff3";
      pull.ff = "only";
      push.autoSetupRemote = true;
    };
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
  };

  programs.nnn = {
    enable = true;
    package = pkgs.nnn.override ({ withNerdIcons = true; });
    bookmarks = {
      l = "~/Code/local";
      r = "~/Code/github.com";
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
      set relativenumber
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
      " set si
      set nowrap
      set backspace=start,eol,indent
      
      " Finding files - Search down into subfolders
      set path+=**
      set wildignore+=*/node_modules/*
      
      " Turn off paste mode when leaving insert
      autocmd InsertLeave * set nopaste
      
      " Toggle paste mode
      nnoremap <F2> :set invpaste paste?<CR>
      "set pastetoggle=<F2>
      
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
      
      " Move lines up or down
      nnoremap <A-j> :m .+1<CR>==
      nnoremap <A-k> :m .-2<CR>==
      inoremap <A-j> <Esc>:m .+1<CR>==gi
      inoremap <A-k> <Esc>:m .-2<CR>==gi
      vnoremap <A-j> :m '>+1<CR>gv=gv
      vnoremap <A-k> :m '<-2<CR>gv=gv
    '';
  };

  # Shell configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    shellAliases = {
      cat = "bat --pager=never";

      cdc = "cd ~/Code";
      cdl = "cd ~/Code/github.com/craigjperry2/sandbox";
      cdr = "cd ~/Code/github.com/craigjperry2";
      cdd = "cd ~/Code/github.com/craigjperry2/dotfiles/dotfiles";

      find = "fd";
      grep = "rg";

      g = "git";
      ga = "g a";
      gac = "g ac";
      gb = "g b";
      gcm = "g cm";
      gd = "g d";
      gdt = "g dt";
      gds = "g ds";
      gdst = "g dst";
      gl = "g show";  # was git log --oneline
      gll = "g l";
      gps = "g ps";
      gpl = "g pl";
      gs = "lazygit";  # was git status for the longest time, hence gs
      gss = "g status";
      gw = "g w";

      l = "eza --git --grid --across --icons -l --header";
      ll = "eza --git -l --colour=always --tree --level=2 --sort time --icons --header";

      mkdir = "mkdir -p";

      sec = "nvim /etc/nix-darwin/flake.nix";
      seh = "nvim /etc/nix-darwin/home.nix";
      sns = "( cd /etc/nix-darwin ; sudo darwin-rebuild switch )";

      uu = "( cd /etc/nix-darwin ; sudo nix flake update ); sns";
    };

    initContent = ''
      # vi mode keybindings
      bindkey -v
      
      # vi style history searching
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
      eval "$(starship init zsh)"
    '';
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      aws = {
        symbol = "  ";
      };

      buf = {
        symbol = " ";
      };

      bun = {
        symbol = " ";
      };

      c = {
        symbol = " ";
      };

      cpp = {
        symbol = " ";
      };

      cmake = {
        symbol = " ";
      };

      conda = {
        symbol = " ";
      };

      crystal = {
        symbol = " ";
      };

      dart = {
        symbol = " ";
      };

      deno = {
        symbol = " ";
      };

      directory = {
        read_only = " 󰌾";
      };

      docker_context = {
        symbol = " ";
      };

      elixir = {
        symbol = " ";
      };

      elm = {
        symbol = " ";
      };

      fennel = {
        symbol = " ";
      };

      fossil_branch = {
        symbol = " ";
      };

      gcloud = {
        symbol = "  ";
      };

      git_branch = {
        symbol = " ";
      };

      git_commit = {
        tag_symbol = "  ";
      };

      golang = {
        symbol = " ";
      };

      guix_shell = {
        symbol = " ";
      };

      haskell = {
        symbol = " ";
      };

      haxe = {
        symbol = " ";
      };

      hg_branch = {
        symbol = " ";
      };

      hostname = {
        ssh_symbol = " ";
      };

      java = {
        symbol = " ";
      };

      julia = {
        symbol = " ";
      };

      kotlin = {
        symbol = " ";
      };

      lua = {
        symbol = " ";
      };

      memory_usage = {
        symbol = "󰍛 ";
      };

      meson = {
        symbol = "󰔷 ";
      };

      nim = {
        symbol = "󰆥 ";
      };

      nix_shell = {
        symbol = " ";
      };

      nodejs = {
        symbol = " ";
      };

      ocaml = {
        symbol = " ";
      };

      os = {
        symbols = {
          Alpaquita = " ";
          Alpine = " ";
          AlmaLinux = " ";
          Amazon = " ";
          Android = " ";
          Arch = " ";
          Artix = " ";
          CachyOS = " ";
          CentOS = " ";
          Debian = " ";
          DragonFly = " ";
          Emscripten = " ";
          EndeavourOS = " ";
          Fedora = " ";
          FreeBSD = " ";
          Garuda = "󰛓 ";
          Gentoo = " ";
          HardenedBSD = "󰞌 ";
          Illumos = "󰈸 ";
          Kali = " ";
          Linux = " ";
          Mabox = " ";
          Macos = " ";
          Manjaro = " ";
          Mariner = " ";
          MidnightBSD = " ";
          Mint = " ";
          NetBSD = " ";
          NixOS = " ";
          Nobara = " ";
          OpenBSD = "󰈺 ";
          openSUSE = " ";
          OracleLinux = "󰌷 ";
          Pop = " ";
          Raspbian = " ";
          Redhat = " ";
          RedHatEnterprise = " ";
          RockyLinux = " ";
          Redox = "󰀘 ";
          Solus = "󰠳 ";
          SUSE = " ";
          Ubuntu = " ";
          Unknown = " ";
          Void = " ";
          Windows = "󰍲 ";
        };
      };

      package = {
        symbol = "󰏗 ";
      };

      perl = {
        symbol = " ";
      };

      php = {
        symbol = " ";
      };

      pijul_channel = {
        symbol = " ";
      };

      pixi = {
        symbol = "󰏗 ";
      };

      python = {
        symbol = " ";
      };

      rlang = {
        symbol = "󰟔 ";
      };

      ruby = {
        symbol = " ";
      };

      rust = {
        symbol = "󱘗 ";
      };

      scala = {
        symbol = " ";
      };

      swift = {
        symbol = " ";
      };

      zig = {
        symbol = " ";
      };

      gradle = {
        symbol = " ";
      };
    };
  };

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}

