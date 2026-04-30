{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./vscode.nix
  ];

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
    gum
    iperf3
    jq
    kubectl
    lazygit
    libwebp
    nmap
    nodejs
    pnpm
    procs
    python3
    ripgrep
    sqlite
    tokei
    uv
    wget
    xan
    yazi
    yt-dlp
    zulu
    python3Packages.python-kasa
  ];

  home.sessionVariables = {
    BAT_THEME = "Solarized (dark)";
    EZA_COLORS = "xx=0";
  };

  programs = {
    direnv = {
      enable = true;
      enableZshIntegration = true;
      stdlib = ''
        layout_uv() {
            if [[ -d ".venv" ]]; then
                VIRTUAL_ENV="$(pwd)/.venv"
            fi

            if [[ -z $VIRTUAL_ENV || ! -d $VIRTUAL_ENV ]]; then
                log_status "No virtual environment exists. Executing `uv venv` to create one."
                uv venv
                VIRTUAL_ENV="$(pwd)/.venv"
            fi

            uv sync

            if [ -d ".venv/bin" ]; then
                PATH_add .venv/bin
            fi

            export UV_ACTIVE=1  # or VENV_ACTIVE=1
            export VIRTUAL_ENV
        }
      '';
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "fd --type f";
    };

    nnn = {
      enable = true;
      package = pkgs.nnn.override {withNerdIcons = true;};
      bookmarks = {
        l = "~/Code/local";
        r = "~/Code/github.com";
        d = "~/Code/github.com";
      };
    };

    git = {
      enable = true;
      settings = {
        user.name = "Craig Perry";
        user.email = "craigp84@gmail.com";
        color.ui = "auto";
        core.pager = "delta";
        delta = {
          navigate = true;
          line-numbers = true;
          side-by-side = true;
          hyperlinks = true;
          syntax-theme = "Solarized (dark)";
        };
        init.defaultBranch = "main";
        interactive.diffFilter = "delta --color-only";
        merge.conflictstyle = "zdiff3";
        pull.ff = "only";
        push.autoSetupRemote = true;
        alias = {
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
          edit-unmerged = "!f() { git ls-files --unmerged | cut -f2 | sort -u ; }; vim `f`";
          add-unmerged = "!f() { git ls-files --unmerged | cut -f2 | sort -u ; }; git add `f`";
        };
      };
    };

    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      plugins = with pkgs.vimPlugins; [
        fzfWrapper
        fzf-vim
        {
          plugin = lualine-nvim;
          type = "lua";
          config = ''
            require('lualine').setup({options={theme='solarized_dark'}})
          '';
        }
        {
          plugin = nnn-vim;
          config = ''
            let g:nnn#layout = {'window': {'width':0.9, 'height':0.6, 'highlight':'Debug'}}
            let g:nnn#action = {'<c-x>': 'split', '<c-v>': 'vsplit'}
          '';
        }
        nvim-web-devicons
        plenary-nvim
        {
          plugin = vim-colors-solarized;
          config = ''
            colorscheme solarized
          '';
        }
        vim-nix
        vim-sneak
        vim-surround
        vim-unimpaired
        {
          plugin = yazi-nvim;
          type = "lua";
          config = ''
            vim.keymap.set("n", "<leader>-", function()
              require("yazi").yazi()
            end)

            vim.g.loaded_netrwPlugin = 1
            vim.api.nvim_create_autocmd("UIEnter", {
              callback = function()
                require("yazi").setup({
                  open_for_directories = true,
                })
              end,
            })
          '';
        }
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
         set background=light

         set inccommand=split

         " Don't redraw while executing macros
         set lazyredraw

         set smarttab
         filetype plugin indent on
         set tabstop=2
         set shiftwidth=2
         set ai
         set nowrap
         set backspace=start,eol,indent

         " Finding files - Search down into subfolders
         set path+=**
         set wildignore+=*/node_modules/*

         " Turn off paste mode when leaving insert
         autocmd InsertLeave * set nopaste

         " Toggle paste mode
         nnoremap <F2> :set invpaste paste?<CR>

         " Add asterisks in block comments
         set formatoptions+=r

         let mapleader=" "

         set cursorline

         " Restore last cursor position on re-opening a file & scroll to middle of screen
         autocmd BufReadPost *
           \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
           \ |   exe "normal! g'\""
           \ |   exe "normal! zz"
           \ | endif

         au BufNewFile,BufRead *.es6 setf javascript
         au BufNewFile,BufRead *.tsx setf typescriptreact
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

    zellij = {
      enable = true;
      enableZshIntegration = false;
      settings = {
        default_mode = "locked";
        attach_to_session = true;
      };
    };

    # Shell configuration
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      shellAliases = {
        cat = "bat --pager=never";

        cdc = "cd ~/Code";
        cdh = "cd ~/Code/github.com/craigjperry2/home-network/";
        cdl = "cd ~/Code/github.com/craigjperry2/";
        cdr = "cd ~/Code/github.com/";
        cdd = "cd ~/Code/github.com/craigjperry2/dotfiles/dotfiles/";

        g = "git";
        ga = "g a";
        gac = "g ac";
        gb = "g b";
        gcm = "g cm";
        gd = "g d";
        gdt = "g dt";
        gds = "g ds";
        gdst = "g dst";
        gl = "g show";
        gll = "g l";
        gps = "g ps";
        gpl = "g pl";
        gs = "lazygit";
        gss = "g status";
        gw = "g w";

        l = "eza --git --grid --across --icons -l --header";
        ll = "eza --git -l --colour=always --tree --level=2 --sort time --icons --header";

        mkdir = "mkdir -p";

        srp = ''ssh s1.home.craigjperry.com "journalctl -u systemd-suspend.service | awk '/Performing sleep/ {sm=\$1; sd=\$2; st=\$3; \"date -d \\\"\"\$1\" \"\$2\" \"\$3\"\\\" +%s\" | getline ss; close(\"date\")} /System returned/ {\"date -d \\\"\"\$1\" \"\$2\" \"\$3\"\\\" +%s\" | getline es; close(\"date\"); d=es-ss; printf \"Suspended on %s %s at %s, slept for %02d:%02d:%02d, woke on %s %s at %s\\n\", sm, sd, st, d/3600, d%3600/60, d%60, \$1, \$2, \$3}'"'';
        why-awake = ''ssh s1.home.craigjperry.com "last_wake=\$(sudo journalctl -u systemd-suspend.service --since '1 week ago' --no-pager | awk '/System returned from sleep/ {last=\$1\\\" \\\"\$2\\\" \\\"\$3} END {print last}'); if [ -n \\\"\$last_wake\\\" ]; then wake_ts=\$(date -d \\\"\$last_wake\\\" +%s); now_ts=\$(date +%s); diff=\$((now_ts - wake_ts)); printf 'Awake for %d minutes\\n' \$((diff / 60)); else uptime; fi; sudo journalctl -u autosuspend.service -n 1 --no-pager | awk '{print \\\"Last check at: \\\" \$1 \\\" \\\" \$2 \\\" \\\" \$3}'; echo 'Active checks:'; sudo journalctl -u autosuspend.service -n 50 --no-pager | awk -F' - ' '/Check .* matched/ {print \$NF}' | sort -u" '';

        sns =
          if pkgs.stdenv.isLinux
          then "( cd ~/Code/github.com/craigjperry2/home-network/nix ; sudo nixos-rebuild switch --flake .#$(hostname -s) )"
          else "( cd ~/Code/github.com/craigjperry2/home-network/nix ; sudo darwin-rebuild switch --flake .#$(hostname -s) )";
        uu = "( cd ~/Code/github.com/craigjperry2/home-network/nix ; nix flake update ); sns";
      };

      initContent = ''
        # vi mode keybindings
        bindkey -v

        # vi style history searching
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

        # Pause 10ms (minimum) before entering cmd mode
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

            nnn -c "$@"

            if [ -f "$NNN_TMPFILE" ]; then
                    . "$NNN_TMPFILE"
                    rm -f "$NNN_TMPFILE" > /dev/null
            fi
        }

        # Yazi integration
        function y() {
        	local tmp="$(mktemp -t "yazi-cwd")"
        	command yazi "$@" --cwd-file="$tmp"
        	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        		builtin cd -- "$cwd"
        	fi
        	rm -f -- "$tmp"
        }

        eval "$(starship init zsh)"

        # Auto-start zellij for SSH connections
        if [[ -n "$SSH_CONNECTION" ]]; then
            export ZELLIJ_AUTO_ATTACH=true
            eval "$(zellij setup --generate-auto-start zsh)"
        fi
      '';
    };

    starship = {
      enable = true;
      settings = {
        add_newline = true;
        # Base settings based on earlier configuration
        aws.symbol = "  ";
        buf.symbol = " ";
        bun.symbol = " ";
        c.symbol = " ";
        cpp.symbol = " ";
        cmake.symbol = " ";
        conda.symbol = " ";
        crystal.symbol = " ";
        dart.symbol = " ";
        deno.symbol = " ";
        directory.read_only = " 󰌾";
        docker_context.symbol = " ";
        elixir.symbol = " ";
        elm.symbol = " ";
        fennel.symbol = " ";
        fossil_branch.symbol = " ";
        gcloud.symbol = "  ";
        git_branch.symbol = " ";
        git_commit.tag_symbol = "  ";
        golang.symbol = " ";
        guix_shell.symbol = " ";
        haskell.symbol = " ";
        haxe.symbol = " ";
        hg_branch.symbol = " ";
        hostname.ssh_symbol = " ";
        java.symbol = " ";
        julia.symbol = " ";
        kotlin.symbol = " ";
        lua.symbol = " ";
        memory_usage.symbol = "󰍛 ";
        meson.symbol = "󰔷 ";
        nim.symbol = "󰆥 ";
        nix_shell.symbol = " ";
        nodejs.symbol = " ";
        ocaml.symbol = " ";
        package.symbol = "󰏗 ";
        perl.symbol = " ";
        php.symbol = " ";
        pijul_channel.symbol = " ";
        pixi.symbol = "󰏗 ";
        python.symbol = " ";
        rlang.symbol = "󰟔 ";
        ruby.symbol = " ";
        rust.symbol = "󱘗 ";
        scala.symbol = " ";
        swift.symbol = " ";
        zig.symbol = " ";
        gradle.symbol = " ";
      };
    };

    # Let Home Manager install and manage itself
    home-manager.enable = true;
  };

  # XDG user directories (Linux only)
  xdg = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };
}
