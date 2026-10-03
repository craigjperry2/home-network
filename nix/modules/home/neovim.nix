# Neovim: plugins and their config. Larger Lua and Vimscript live in
# ./neovim so they can be edited and linted as real files.
{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withRuby = false;
    withPython3 = false;
    plugins = with pkgs.vimPlugins; [
      fzf-wrapper
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
        type = "viml";
        config = ''
          let g:nnn#layout = {'window': {'width':0.9, 'height':0.6, 'highlight':'Debug'}}
          let g:nnn#action = {'<c-x>': 'split', '<c-v>': 'vsplit'}
        '';
      }
      nvim-web-devicons
      {
        plugin = nvim-treesitter.withAllGrammars;
        type = "lua";
        config = ''
          require("nvim-treesitter").setup({})

          vim.api.nvim_create_autocmd("FileType", {
            callback = function(args)
              pcall(vim.treesitter.start, args.buf)
            end,
          })
        '';
      }
      {
        plugin = nvim-treesitter-textobjects;
        type = "lua";
        config = builtins.readFile ./neovim/textobjects.lua;
      }
      plenary-nvim
      {
        plugin = vim-colors-solarized;
        type = "viml";
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
    extraConfig = builtins.readFile ./neovim/init.vim;
  };
}
