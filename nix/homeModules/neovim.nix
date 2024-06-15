# Power of “NEO”

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lunik1.home.neovim;
in
{
  options.lunik1.home.neovim.enable = lib.mkEnableOption "Neovim";

  config = lib.mkIf cfg.enable {
    lunik1.home = {
      git.enable = true;
      lang.viml.enable = true;
    };

    home = {
      sessionVariables = {
        EDITOR = "nvim";
      };

      packages = with pkgs; lib.optionals config.lunik1.home.gui.enable [ neovide ];
    };

    programs = {
      nixvim =
        let
          cmd = s: "<cmd>${s}<cr>";
          function = s: { __raw = "function() ${s} end"; };

          genghis = pkgs.vimUtils.buildVimPlugin {
            pname = "nvim-genghis";
            version = "2024-06-04";
            src = pkgs.fetchFromGitHub {
              owner = "chrisgrieser";
              repo = "nvim-genghis";
              rev = "7055134943460d962b4909b43b4c3cd5f011c153";
              sha256 = "sha256-qLMJt0GYFv/S9eruGFKBMd26vNZvKf5ynRgE37iKros=";
            };
          };
        in
        {
          enable = true;
          vimAlias = true;

          extraConfigLuaPre = ''
            vim.keymap.set('n', '<Space>', '<Nop>', { silent = true, remap = false })
            vim.g.mapleader = ' '
            vim.g.maplocaleader = ' '
          '';

          autoCmd = [
            {
              event = [ "TextYankPost" ];
              pattern = [ "*" ];
              callback = function "vim.highlight.on_yank {higroup='IncSearch', timeout=150, on_visual=true}";
            }
            {
              event = [
                "BufNewFile"
                "BufRead"
              ];
              pattern = [ "*.bb" ];
              callback = function "vim.bo.filetype = 'clojure'";
            }
            {
              event = [ "TermOpen" ];
              command = "setlocal nonumber norelativenumber";
            }
            {
              event = [ "CursorHold" ];
              callback = function "vim.diagnostic.open_float(0, {scope='cursor'})";
            }
          ];

          clipboard = {
            register = "unnamedplus";
            providers.wl-copy.enable = true;
          };

          colorschemes.gruvbox.enable = true;

          globals = {
            mapLeader = " ";
            netrw_browsex_viewer = "xdg-open";
            tex_flavour = "latex";
            neovide_cursor_vfx_mode = "railgun";
            neovide_cursor_vfx_particle_density = 10.0;
            neovide_cursor_animation_length = 5.0e-2;
            neovide_cursor_animate_in_insert_mode = false;
          };

          keymaps = [
            # Create blank lines with return in normal mode
            {
              key = "<cr>";
              action = "o<esc>";
              mode = "n";
              options.silent = true;
            }
            {
              key = "<s-enter>";
              action = "O<esc>";
              mode = "n";
              options.silent = true;
            }

            # Clear search highlight with Esc
            {
              key = "<esc>";
              action = "<cmd>noh<cr><esc>";
              options = {
                silent = true;
                noremap = true;
              };
            }

            # Unimpaired-like mappings (I think the actual package has too many)
            # buffers
            {
              key = "]b";
              action = cmd "execute 'bnext' . v:count1";
              mode = "n";
              options.silent = true;
            }
            {
              key = "[b";
              action = cmd "execute 'bprevious' . v:count1";
              mode = "n";
              options.silent = true;
            }
            {
              key = "]B";
              action = cmd "blast";
              mode = "n";
              options.silent = true;
            }
            {
              key = "]B";
              action = cmd "bfirst";
              mode = "n";
              options.silent = true;
            }
            # tabs
            {
              key = "]<tab>";
              action = cmd "tabnext";
              mode = "n";
            }
            {
              key = "[<tab>";
              action = cmd "tabprevious";
              mode = "n";
            }
            {
              key = "<leader>]<tab>";
              action = cmd "tabnext";
              mode = "n";
            }
            {
              key = "<leader>[<tab>";
              action = cmd "tabprevious";
              mode = "n";
            }
            {
              key = "]<s-tab>";
              action = cmd "tablast";
              mode = "n";
            }
            {
              key = "]<s-tab>";
              action = cmd "tabfirst";
              mode = "n";
            }
            # quickfix list
            {
              key = "]q";
              action = cmd "execute 'cnext' . v:count1";
              mode = "n";
            }
            {
              key = "[q";
              action = cmd "execute 'cprevious' . v:count1";
              mode = "n";
            }
            {
              key = "]Q";
              action = cmd "clast";
              mode = "n";
            }
            {
              key = "]Q";
              action = cmd "cnext";
              mode = "n";
            }
            # diagnostics
            {
              key = "]e";
              action = function "vim.diagnostic.goto_next( { float = false } )";
              mode = "n";
            }
            {
              key = "[e";
              action = function "vim.diagnostic.goto_prev( { float = false } )";
              mode = "n";
            }

            # Toggles
            {
              key = "<leader>ti";
              action = function ''
                require('ibl').setup_buffer(0, {
                  enabled = not require('ibl.config').get_config(0).enabled,
                })
              '';
            }
            {
              key = "<leader>tl";
              action = cmd "setlocal number!";
            }
            {
              key = "<leader>tR"; # R for Rainbow
              action = cmd "ColorizerToggle";
            }
            {
              key = "<leader>tr";
              action = cmd "setlocal readonly!";
            }
            {
              key = "<leader>ts";
              action = cmd "setlocal spell!";
            }
            {
              key = "<leader>tv";
              action = cmd "setlocal list!";
            }
            {
              key = "<leader>tw";
              action = cmd "setlocal wrap!";
            }

            # Telescope
            {
              key = "<leader><space>";
              action = cmd "Telescope git_files";
            }
            {
              key = "<leader>/";
              action = ":Telescope live_grep<cr>";
            }
            {
              key = "<leader>bb";
              action = cmd "Telescope buffers";
            }
            {
              key = "<leader>:";
              action = cmd "Telescope commands";
            }
            {
              key = "<a-x>:";
              action = cmd "Telescope commands";
            }
            {
              key = "<leader>iy";
              action = cmd "Telescope registers";
            }
            {
              key = "<leader>ss";
              action = cmd "Telescope current_buffer_fuzzy_find";
            }
            {
              key = "<leader>fr";
              action = cmd "Telescope oldfiles";
            }

            # Windows
            {
              key = "<leader>w=";
              action = cmd "wincmd =";
            }
            {
              key = "<leader>wc";
              action = cmd "close";
            }
            {
              key = "<leader>wd";
              action = cmd "close";
            }
            {
              key = "<leader>wm";
              action = cmd "only";
            }
            {
              key = "<leader>wR";
              action = cmd "wincmd R";
            }
            {
              key = "<leader>wr";
              action = cmd "wincmd r";
            }
            {
              key = "<leader>ws";
              action = cmd "split";
            }
            {
              key = "<leader>wv";
              action = cmd "vsplit";
            }
            {
              key = "<leader>wx";
              action = cmd "wincmd x";
            }

            {
              key = "<c-w><s-left>";
              action = "<c-w>H";
              options.silent = true;
            }
            {
              key = "<c-w><s-right>";
              action = "<c-w>L";
              options.silent = true;
            }
            {
              key = "<c-w><s-up>";
              action = "<c-w>K";
              options.silent = true;
            }
            {
              key = "<c-w><s-down>";
              action = "<c-w>K";
              options.silent = true;
            }

            # Tabs
            {
              key = "<leader><tab>`";
              action = cmd "tabnext #";
            }
            {
              key = "<leader><tab>d";
              action = cmd "tabclose";
            }
            {
              key = "<leader><tab>n";
              action = cmd "tabnew";
            }

            # Files
            {
              key = "<leader>fC";
              action = function "require('genghis').duplicateFile()";
            }
            {
              key = "<leader>fD";
              action = function "require('genghis').trashFile()";
            }
            {
              key = "<leader>fR";
              action = function "require('genghis').moveAndRenameFile()";
            }
            {
              key = "<leader>fr";
              action = cmd "Telescope oldfiles";
            }
            {
              key = "<leader>fs";
              action = cmd "write";
            }
            {
              key = "<leader>fy";
              action = function "require('genghis').copyFilepath()";
            }

            # Sessions 
            {
              key = "<leader>pa";
              action = cmd "SessionSave";
            }
            {
              key = "<leader>pd";
              action = cmd "SessionDelete";
            }
            {
              key = "<leader>pP";
              action = cmd "SessionPurgeOrphaned";
            }
            {
              key = "<leader>pp";
              action = cmd "Telescope session-lens";
            }

            # Navbuddy
            {
              key = "<leader>cn";
              action = cmd "Navbuddy";
            }

            # Neogit
            {
              key = "<leader>gg";
              action = cmd "Neogit";
            }

            # Format
            {
              key = "<leader>cf";
              action = function "vim.lsp.buf.format()";
            }

            # Intellitab + cmp
            {
              key = "<tab>";
              mode = [
                "i"
                "s"
              ];
              action = {
                __raw = ''
                  function(fallback)
                    if cmp.visible() then
                      cmp.select_next_item()
                    else
                      require('intellitab').indent()
                    end
                  end
                '';
              };
            }

            # Other buffer
            {
              key = "<leader>`";
              action = cmd "buffer#";
            }

            # Terminal
            {
              key = "<leader>oT";
              action = cmd ":terminal";
            }
            {
              key = "<leader>ot";
              action = function "require('FTerm').toggle()";
            }
            {
              key = "<s-esc>";
              action = "<c-\\><c-n>";
              mode = "t";
            }

            # Oil
            {
              key = "<leader>o-";
              action = cmd ":Oil";
            }
          ];

          opts = {
            background = "dark";
            diffopt = "filler,internal,algorithm:histogram,indent-heuristic,followwrap";
            cursorline = true;
            expandtab = true;
            foldlevel = 99;
            guifont = "Myosevka:h14.0";
            ignorecase = true;
            incsearch = true;
            lazyredraw = true;
            mouse = "a";
            number = true;
            relativenumber = true;
            pumblend = 15;
            pumheight = 8;
            scrolloff = 5;
            shiftwidth = 4;
            sidescrolloff = 10;
            signcolumn = "yes";
            smartcase = true;
            softtabstop = 4;
            spelllang = "en_gb";
            splitbelow = true;
            splitright = true;
            tabstop = 4;
            termguicolors = true;
            undofile = true;
            updatetime = 250;
            visualbell = true;
            winblend = 15;
          };

          plugins = {
            auto-session = {
              enable = true;
              autoRestore.enabled = false;
              autoSession = {
                enableLastSession = false;
                createEnabled = false;
                useGitBranch = false;
              };
            };

            barbecue.enable = true;

            cmp = {
              enable = true;
              cmdline = {
                ":" = {
                  mapping = {
                    __raw = "cmp.mapping.preset.cmdline()";
                  };
                  sources = [
                    { name = "cmdline"; }
                    { name = "cmdline_history"; }
                    { name = "path"; }
                    { name = "buffer"; }
                  ];
                };
                "/" = {
                  mapping = {
                    __raw = "cmp.mapping.preset.cmdline()";
                  };
                  sources = [ { name = "buffer"; } ];
                };
              };
              settings = {
                mapping = {
                  "<c-p>" = "cmp.mapping.select_prev_item()";
                  "<c-n>" = "cmp.mapping.select_next_item()";
                  "<c-d>" = "cmp.mapping.scroll_docs(-4)";
                  "<c-f>" = "cmp.mapping.scroll_docs(4)";
                  "<c-space>" = "cmp.mapping.complete()";
                  "<c-e>" = "cmp.mapping.close()";
                  "<s-tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
                };
                preselect = "cmp.PreselectMode.None";
                snippet.expand = ''
                  function(args)
                    vim.snippet.expand(args.body)
                  end
                '';
                sources = [
                  { name = "async_path"; }
                  { name = "buffer"; }
                  { name = "nvim_lsp"; }
                  { name = "nvim_lsp_document_symbol"; }
                  { name = "nvim_lua"; }
                  { name = "omni"; }
                  { name = "treesitter"; }
                  { name = "zsh"; }
                ];
              };
            };

            cmp-async-path.enable = true;

            cmp-buffer.enable = true;

            cmp-cmdline.enable = true;

            cmp-cmdline-history.enable = true;

            cmp-nvim-lsp.enable = true;

            cmp-nvim-lsp-document-symbol.enable = true;

            cmp-nvim-lua.enable = true;

            cmp-omni.enable = true;

            cmp-treesitter.enable = true;

            cmp-zsh.enable = true;

            direnv.enable = true;

            dressing = {
              enable = true;
              settings.select.backend = [ "builtin" ];
            };

            gitsigns = {
              enable = true;
              gitPackage = null;
              settings = {
                signs = {
                  add.text = "+";
                  change.text = "~";
                  delete.text = "_";
                  topdelete.text = "‾";
                  changedelete.text = "≁";
                  untracked.text = "┆";
                };
              };
            };

            indent-blankline = {
              enable = true;
              settings.indent.char = [
                "│"
                "¦"
                "┆"
                "┊"
              ];
            };

            intellitab.enable = true;

            lsp = {
              enable = true;
              keymaps = {
                lspBuf = {
                  gD = "references";
                  gd = "definition";
                  gI = "implementation";
                  gi = "implementation";
                  gt = "type_definition";
                };
                extra = [
                  {
                    key = "<leader>lr";
                    action = "<cmd>LspRestart<enter>";
                  }
                  {
                    key = "<c-k>";
                    action = function "vim.lsp.buf.signature_help()";
                  }
                  {
                    key = "<leader>cd";
                    action = function "vim.lsp.buf.definition()";
                  }
                  {
                    key = "<leader>cD";
                    action = function "vim.lsp.buf.references()";
                  }
                  {
                    key = "<leader>cr";
                    action = function "vim.lsp.buf.rename()";
                  }
                  {
                    key = "<leader>ct";
                    action = function "vim.lsp.buf.type_definition()";
                  }
                  {
                    key = "<leader>ca";
                    action = function "vim.lsp.buf.code_action()";
                    mode = "n";
                  }
                  {
                    key = "<leader>ca";
                    action = function "vim.lsp.buf.range_code_action()";
                    mode = "v";
                  }
                ];
              };
              servers = {
                bashls = {
                  enable = true;
                  package = pkgs.nodePackages_latest.bash-language-server;
                };
                beancount = {
                  enable = true;
                  package = null;
                };
                clojure-lsp.enable = config.lunik1.home.lang.clojure.enable;
                digestif.enable = true;
                dockerls.enable = true;
                jsonls.enable = config.lunik1.home.lang.data.enable;
                lua-ls.enable = true;
                marksman.enable = true;
                nil-ls = {
                  inherit (config.lunik1.home.lang.nix) enable;
                  settings.formatting.command = [ "nixfmt" ];
                };
                pylsp = {
                  inherit (config.lunik1.home.lang.python) enable;
                  package = null;
                  extraOptions = { };
                };
                ruff-lsp = {
                  inherit (config.lunik1.home.lang.rust) enable;
                  package = null;
                };
                rust-analyzer = {
                  inherit (config.lunik1.home.lang.rust) enable;
                  installCargo = true;
                  installRustc = true;
                };
                taplo.enable = config.lunik1.home.lang.data.enable;
                typos-lsp.enable = true;
                yamlls.enable = config.lunik1.home.lang.data.enable;
              };
            };

            lspkind = {
              enable = true;
              cmp.enable = true;
            };

            lualine.enable = true;

            oil.enable = true;

            navbuddy = {
              enable = true;
              keymapsSilent = true;
              lsp.autoAttach = true;
              mappings = {
                "<Left>" = "parent";
                "<Right>" = "children";
              };
            };

            neogit = {
              enable = true;
              settings.mappings.popup = {
                # DOOM + Magit-like
                "?" = "HelpPopup";
                "A" = "CherryPickPopup";
                "B" = "BisectPopup";
                "D" = "DiffPopup";
                "F" = "PullPopup";
                "M" = "RemotePopup";
                "V" = "RevertPopup";
                "X" = "ResetPopup";
                "Z" = "WorktreePopup";
                "b" = "BranchPopup";
                "c" = "CommitPopup";
                "f" = "FetchPopup";
                "l" = "LogPopup";
                "m" = "MergePopup";
                "p" = "PushPopup";
                "r" = "RebasePopup";
                "z" = "StashPopup";
              };
            };

            none-ls = {
              enable = true;
              sources = {
                code_actions = {
                  proselint.enable = true;
                  statix.enable = true;
                };
                diagnostics = {
                  deadnix.enable = true;
                  markdownlint_cli2.enable = true;
                  statix.enable = config.lunik1.home.lang.nix.enable;
                  write_good.enable = true;
                  yamllint.enable = config.lunik1.home.lang.nix.enable;
                  zsh.enable = true;
                };
                formatting = {
                  shfmt.enable = true;
                };
              };
            };

            notify = {
              enable = true;
              fps = 60;
              maxWidth = 80;
              maxHeight = 5;
            };

            nvim-autopairs.enable = true;

            nvim-colorizer.enable = true;

            nvim-lightbulb = {
              enable = true;
              settings = {
                autocmd.enabled = true;
              };
            };

            rainbow-delimiters.enable = true;

            telescope = {
              enable = true;
              extensions = {
                fzf-native.enable = true;
              };
            };

            sleuth.enable = true;

            surround.enable = true;

            treesitter = {
              enable = true;
              folding = true;
              indent = true;
              nixvimInjections = true;
              incrementalSelection.enable = true;
            };

            treesitter-textobjects = {
              enable = true;
              move = {
                enable = true;
                setJumps = true;
                gotoNextStart = {
                  "]a" = {
                    query = "@parameter.inner";
                  };
                  "]C" = {
                    query = "@class.outer";
                  };
                  "]c" = {
                    query = "@comment.inner";
                  };
                  "]F" = {
                    query = "@call.inner";
                  };
                  "]f" = {
                    query = "@function.outer";
                  };
                  "]k" = {
                    query = "@block.outer";
                  };
                  "]l" = {
                    query = "@loop.outer";
                  };
                  "]v" = {
                    query = "@conditional.outer";
                  };
                };
                gotoPreviousStart = {
                  "[a" = {
                    query = "@parameter.inner";
                  };
                  "[C" = {
                    query = "@class.outer";
                  };
                  "[c" = {
                    query = "@comment.inner";
                  };
                  "[F" = {
                    query = "@call.inner";
                  };
                  "[f" = {
                    query = "@function.outer";
                  };
                  "[k" = {
                    query = "@block.outer";
                  };
                  "[l" = {
                    query = "@loop.outer";
                  };
                  "[v" = {
                    query = "@conditional.outer";
                  };
                };
              };
              select = {
                enable = true;
                lookahead = true;
                keymaps = {
                  aA = {
                    query = "@parameter.outer";
                  };
                  iA = {
                    query = "@parameter.inner";
                  };
                  aC = {
                    query = "@class.outer";
                  };
                  iC = {
                    query = "@class.inner";
                  };
                  ac = {
                    query = "@comment.outer";
                  };
                  ic = {
                    query = "@comment.inner";
                  };
                  af = {
                    query = "@function.outer";
                  };
                  "if" = {
                    query = "@function.inner";
                  };
                  aF = {
                    query = "@call.outer";
                  };
                  iF = {
                    query = "@call.inner";
                  };
                  ak = {
                    query = "@block.outer";
                  };
                  ik = {
                    query = "@block.inner";
                  };
                  al = {
                    query = "@loop.outer";
                  };
                  il = {
                    query = "@loop.inner";
                  };
                  av = {
                    query = "@conditional.outer";
                  };
                  iv = {
                    query = "@conditional.inner";
                  };
                };
              };
            };

            vim-matchup = {
              enable = true;
              enableSurround = true;
              treesitterIntegration.enable = true;
            };
          };

          extraConfigLua = ''
            vim.opt.formatoptions:append { 'o', 'r' }

            vim.diagnostic.config({
              virtual_text = false,
              signs = false,
              underline = true,
              update_in_insert = false,
              severity_sort = true,
              float = { source = 'always', border = 'rounded' },
            })

            vim.api.nvim_set_hl(0, 'CursorLine', { bg = '#1d2021' })
            vim.api.nvim_set_hl(0, 'Floatborder', { bg = vim.api.nvim_get_hl_by_name('Normal', true).background })

            vim.api.nvim_set_hl(
              0,
              'DiagnosticUnderlineError',
                {
                  sp = vim.api.nvim_get_hl_by_name('DiagnosticUnderlineError', true).special,
                  underdotted = true
                }
            )
            vim.api.nvim_set_hl(
              0,
              'DiagnosticUnderlineWarn',
                {
                  sp = vim.api.nvim_get_hl_by_name('DiagnosticUnderlineWarn', true).special,
                  underdotted = true
                }
            )
            vim.api.nvim_set_hl(
              0,
              'DiagnosticUnderlineInfo',
                {
                  sp = vim.api.nvim_get_hl_by_name('DiagnosticUnderlineInfo', true).special,
                  underdotted = true
                }
            )
            vim.api.nvim_set_hl(
              0,
              'DiagnosticUnderlineHint',
                {
                  sp = vim.api.nvim_get_hl_by_name('DiagnosticUnderlineHint', true).special,
                  underdotted = true
                }
            )

            vim.fn.digraph_setlist(
              {
                {'*e', 'ϵ'},
                {'*f', 'ϖ'},
                {'*h', 'ϑ'},
                {'*r', 'ϱ'},
                {'h-', 'ℏ'},
              }
            )

            require'FTerm'.setup({
                border = 'rounded',
                blend = 15,
            })

            if vim.g.neovide then
                vim.keymap.set(
                  '!',
                  '<s-insert>',
                  function() vim.api.nvim_put({ vim.fn.getreg('*') }, ${"''"}, true, true) end
                )
                vim.keymap.set(
                  '!',
                  '<c-s-v>',
                  function() vim.api.nvim_put({ vim.fn.getreg('+') }, ${"''"}, true, true) end
                )
            end
          '';

          extraPlugins = with pkgs.vimPlugins; [
            FTerm-nvim
            genghis
            plenary-nvim
            project-nvim
            vim-lion
            vim-repeat
            vim-sleuth
            vim-sneak
          ];
        };

      zsh.shellAliases = rec {
        neogit = "nvim +Neogit";
        vimdiff = "nvim -d";
        nvimdiff = vimdiff;
      };
    };
  };
}
