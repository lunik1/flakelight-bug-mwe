{ config, lib, pkgs, ... }:

let cfg = config.lunik1.home.neovim;
in {
  options.lunik1.home.neovim.enable = lib.mkEnableOption "Neovim";

  config = lib.mkIf cfg.enable {
    lunik1.home = {
      git.enable = true;
      lang.viml.enable = true;
    };

    home = { sessionVariables.EDITOR = "nvim"; };

    pam.sessionVariables.EDITOR = "nvim";

    programs.neovim = let
      nvim-treesitter = (pkgs.vimPlugins.nvim-treesitter.withPlugins
        (plugins: pkgs.tree-sitter.allGrammars));
      idris2-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix {
        pname = "idris2-nvim";
        version = "2022-12-01";
        src = pkgs.fetchFromGitHub {
          owner = "ShinKage";
          repo = "idris2-nvim";
          rev = "dd850c1c67bcacd2395121b0898374fe9cdd228f";
          sha256 = "sha256-gwB2tkPT9gmg137durmgtjZw9HfEssY/oSI57saZwp8=";
        };
        meta.homepage = "https://github.com/ShinKage/idris2-nvim/commits/main";
      };
    in {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withNodeJs = true;
      extraPackages = with pkgs; [ fd ripgrep wl-clipboard xclip ];
      plugins = with pkgs.vimPlugins; [
        {
          plugin = cmp-nvim-lsp;
          type = "lua";
          config = ''
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
          '';
        }
        cmp_luasnip
        {
          plugin = comment-nvim;
          type = "lua";
          config = ''
            require('Comment').setup {
              ignore = '^$',
            }
          '';
        }
        {
          plugin = gitsigns-nvim;
          type = "lua";
          config = ''
            require('gitsigns').setup {
              signs = {
                add = { hl = 'GitGutterAdd', text = '+' },
                change = { hl = 'GitGutterChange', text = '~' },
                delete = { hl = 'GitGutterDelete', text = '_' },
                topdelete = { hl = 'GitGutterDelete', text = '‾' },
                changedelete = { hl = 'GitGutterChange', text = '≁' },
              },
            }
          '';
        }
        {
          plugin = gruvbox-nvim;
          config = ''
            colorscheme gruvbox
            set background=dark
            set termguicolors
          '';
        }
        {
          plugin = idris2-nvim;
          type = "lua";
          config = "require('idris2').setup({})";
        }
        julia-vim
        {
          plugin = lexima-vim;
          config = ''
            let g:lexima_enable_basic_rules = 0
            let g:lexima_enable_endwise_rules = 0
          '';
        }
        {
          plugin = indent-blankline-nvim;
          config = ''
            let g:indent_blankline_char_list=['┃', '╏', '┇', '┋', '│', '¦', '┆', '┊']
            let g:indent_blankline_filetype_exclude=['help']
            let g:indent_blankline_buftype_exclude=['terminal', 'nofile']
          '';
        }
        {
          plugin = lualine-nvim;
          type = "lua";
          config = "require('lualine').setup()";
        }
        nui-nvim # required by idris2-nvim
        {
          plugin = nvim-colorizer-lua;
          type = "lua";
          config = "require('colorizer').setup()";
        }
        {
          plugin = neogit;
          config = ''
            lua require('neogit').setup()
          '';
        }
        {
          plugin = nvim-cmp;
          type = "lua";
          config = (builtins.readFile ../../config/nvim/plugins/nvim-cmp.lua);
        }
        {
          plugin = nvim-lspconfig;
          type = "lua";
          config =
            (builtins.readFile ../../config/nvim/plugins/nvim-lspconfig.lua);
        }
        {
          plugin = nvim-treesitter;
          type = "lua";
          config =
            (builtins.readFile ../../config/nvim/plugins/nvim-treesitter.lua);
        }
        {
          plugin = nvim-ts-rainbow;
          type = "lua";
          config = ''
            require'nvim-treesitter.configs'.setup {
              rainbow = {
                enable = true,
                extended_mode = true,
                max_file_lines = nil,
              }
            }
          '';
        }
        nvim-treesitter-textobjects
        # nvim-web-devicons
        luasnip
        plenary-nvim
        {
          plugin = telescope-nvim;
          config = ''
            nnoremap <leader><SPACE> <cmd>Telescope git_files<cr>
            nnoremap <leader>pf <cmd>Telescope git_files<cr>
            nnoremap <leader>/ <cmd>Telescope live_grep<cr>
            nnoremap <leader>bb <cmd>Telescope buffers<cr>
            nnoremap <leader>: <cmd>Telescope commands<cr>
            nnoremap <leader>: <cmd>Telescope commands<cr>
            nnoremap <leader>iy <cmd>Telescope registers<cr>
            nnoremap <leader>ss <cmd>Telescope current_buffer_fuzzy_find<cr>
            nnoremap <leader>fr <cmd>Telescope oldfiles<cr>
          '';
        }
        {
          plugin = telescope-fzf-native-nvim;
          type = "lua";
          config = ''
            require('telescope').load_extension 'fzf'
          '';
        }
        {
          plugin = vim-eunuch;
          config = ''
            nnoremap <leader>fd :Delete<cr>
            nnoremap <leader>fr :Rename<cr>
          '';
        }
        vim-lion
        vim-nix
        vim-repeat
        vim-sleuth
        vim-sneak
        vim-surround
        vim-toml
      ];
      extraConfig = builtins.readFile ../../config/nvim/init.vim;
    };
  };
}
