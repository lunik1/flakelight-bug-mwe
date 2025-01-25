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
    };

    programs = {
      nixvim =
        let
          cmd = s: "<cmd>${s}<cr>";
          function = s: { __raw = "function() ${s} end"; };

          agitator = pkgs.vimUtils.buildVimPlugin {
            pname = "agitator";
            version = "2024-12-02";
            doCheck = false;
            src = pkgs.fetchFromGitHub {
              owner = "emmanueltouzery";
              repo = "agitator.nvim";
              rev = "dc2843869b8bb9e5096edf53583b1dee1e62aa6b";
              sha256 = "sha256-9vb8QGJiTmFE77fp8DqaeOI3WtDIthpPW7zvwCQsp4k=";
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

            local function toggle_inlay_hints(client, enable)
              if client.resolved_capabilities.document_highlight then
                client.notify('workspace/didChangeConfiguration', {
                  settings = {
                    inlayHints = {
                      enabled = enable,
                    },
                  },
                })
              end
            end

            local function toggle_transparency()
              if vim.g.neovide_transparency == 1.0 then
                vim.g.neovide_transparency = 0.8
              else
                vim.g.neovide_transparency = 1.0
              end
            end
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
            {
              event = [ "FileType" ];
              pattern = "qf";
              callback = function "vim.api.nvim_buf_set_keymap(0, 'n', '<CR>', ':<C-u>.cc<CR>', { noremap = true, silent = true })";
            }
          ];

          clipboard =
            {
              providers.wl-copy.enable = true;
            }
            // lib.optionalAttrs (config.lunik1.home.gui.enable || pkgs.stdenv.isDarwin) {
              register = "unnamedplus";
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
            qs_buftype_blacklist = [
              "nofile"
              "terminal"
            ];
          };

          keymaps = [
            # Disable suspend
            {
              key = "<c-z>";
              action = "<nop>";
              options.silent = true;
            }

            # Create blank lines with return in normal mode
            {
              key = "<cr>";
              action = "o<esc>";
              mode = "n";
              options = {
                silent = true;
                desc = "Insert empty line below";
              };
            }
            {
              key = "<s-enter>";
              action = "O<esc>";
              mode = "n";
              options = {
                silent = true;
                desc = "Insert empty line above";
              };
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

            # < > retain selection
            {
              key = "<";
              action = "<gv";
              mode = "v";
              options = {
                silent = true;
                noremap = true;
              };
            }
            {
              key = ">";
              action = ">gv";
              mode = "v";
              options = {
                silent = true;
                noremap = true;
              };
            }

            # Delete words with ctrl+backspace
            {
              key = "<c-bs>";
              action = "<c-w>";
              mode = [
                "i"
                "c"
                "t"
              ];
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
              options = {
                silent = true;
                desc = "Next buffer";
              };
            }
            {
              key = "[b";
              action = cmd "execute 'bprevious' . v:count1";
              mode = "n";
              options = {
                silent = true;
                desc = "Previous buffer";
              };
            }
            {
              key = "]B";
              action = cmd "blast";
              mode = "n";
              options = {
                silent = true;
                desc = "Last buffer";
              };
            }
            {
              key = "[B";
              action = cmd "bfirst";
              mode = "n";
              options = {
                silent = true;
                desc = "First buffer";
              };
            }
            # tabs
            {
              key = "]<tab>";
              action = cmd "tabnext";
              mode = "n";
              options.desc = "Next tab";
            }
            {
              key = "[<tab>";
              action = cmd "tabprevious";
              mode = "n";
              options.desc = "Previous tab";
            }
            {
              key = "<leader>]<tab>";
              action = cmd "tabnext";
              mode = "n";
              options.desc = "Next tab";
            }
            {
              key = "<leader>[<tab>";
              action = cmd "tabprevious";
              mode = "n";
              options.desc = "Previous tab";
            }
            {
              key = "]<s-tab>";
              action = cmd "tablast";
              mode = "n";
              options.desc = "Last tab";
            }
            {
              key = "]<s-tab>";
              action = cmd "tabfirst";
              mode = "n";
              options.desc = "First tab";
            }
            # quickfix list
            {
              key = "]q";
              action = cmd "execute 'cnext' . v:count1";
              mode = "n";
              options.desc = "Next quickfix";
            }
            {
              key = "[q";
              action = cmd "execute 'cprevious' . v:count1";
              mode = "n";
              options.desc = "Previous quickfix";
            }
            {
              key = "]Q";
              action = cmd "clast";
              mode = "n";
              options.desc = "Last quickfix";
            }
            {
              key = "]Q";
              action = cmd "cfirst";
              mode = "n";
              options.desc = "First quickfix";
            }
            # diagnostics
            {
              key = "]e";
              action = function "vim.diagnostic.goto_next( { float = false } )";
              mode = "n";
              options.desc = "Next diagnostic";
            }
            {
              key = "[e";
              action = function "vim.diagnostic.goto_prev( { float = false } )";
              mode = "n";
              options.desc = "Previous diagnostic";
            }

            # Toggles
            {
              key = "<leader>tI";
              action = function "vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())";
              options.desc = "Inlay hints";
            }
            {
              key = "<leader>ti";
              action = function ''
                require('ibl').setup_buffer(0, {
                  enabled = not require('ibl.config').get_config(0).enabled,
                })
              '';
              options.desc = "Indent guides";
            }
            {
              key = "<leader>tl";
              action = cmd "setlocal number! | setlocal relativenumber!";
              options.desc = "Line numbers";
            }
            {
              key = "<leader>tR"; # R for Rainbow
              action = cmd "ColorizerToggle";
              options.desc = "Colorizer";
            }
            {
              key = "<leader>tr";
              action = cmd "setlocal readonly!";
              options.desc = "Read-only";
            }
            {
              key = "<leader>ts";
              action = cmd "setlocal spell!";
              options.desc = "Spell-checker";
            }
            {
              key = "<leader>tv";
              action = cmd "setlocal list!";
              options.desc = "Whitespace visibility";
            }
            {
              key = "<leader>tw";
              action = cmd "setlocal wrap!";
              options.desc = "Soft line wrapping";
            }

            # Sneak F/f T/t
            {
              key = "F";
              action = "<Plug>Sneak_F";
              options.desc = "Move to previous char";
            }
            {
              key = "f";
              action = "<Plug>Sneak_f";
              options.desc = "Move to next char";
            }
            {
              key = "t";
              action = "<Plug>Sneak_T";
              options.desc = "Move before previous char";
            }
            {
              key = "t";
              action = "<Plug>Sneak_t";
              options.desc = "Move before next char";
            }

            # Telescope
            {
              key = "<leader><space>";
              action = cmd "Telescope git_files";
              options.desc = "Find file in repository";
            }
            {
              key = "<leader>/";
              action = ":Telescope live_grep<cr>";
              options.desc = "Live grep";
            }
            {
              key = "<leader>bb";
              action = cmd "Telescope buffers";
              options.desc = "Search buffers";
            }
            {
              key = "<leader>:";
              action = cmd "Telescope commands";
              options.desc = "Search commands";
            }
            {
              key = "<m-x>";
              action = cmd "Telescope commands";
              options.desc = "Search commands";
            }
            {
              key = "<leader>iy";
              action = cmd "Telescope registers";
              options.desc = "Search registers";
            }
            {
              key = "<leader>ss";
              action = cmd "Telescope current_buffer_fuzzy_find";
              options.desc = "Search buffer";
            }

            # Windows
            {
              key = "<leader>w=";
              action = cmd "wincmd =";
              options.desc = "Balance windows";
            }
            {
              key = "<leader>wc";
              action = cmd "close";
              options.desc = "Close window";
            }
            {
              key = "<leader>wd";
              action = cmd "close";
              options.desc = "Close window";
            }
            {
              key = "<leader>wo";
              action = cmd "only";
              options.desc = "Maximise window";
            }
            {
              key = "<leader>wm";
              action = cmd "only";
              options.desc = "Maximise window";
            }
            {
              key = "<leader>wR";
              action = cmd "wincmd R";
              options.desc = "Rotate windows up/leftwards";
            }
            {
              key = "<leader>wr";
              action = cmd "wincmd r";
              options.desc = "Rotate windows down/rightwards";
            }
            {
              key = "<leader>ws";
              action = cmd "split";
              options.desc = "Split windows horizontally";
            }
            {
              key = "<leader>wv";
              action = cmd "vsplit";
              options.desc = "Split windows vertically";
            }
            {
              key = "<leader>wx";
              action = cmd "wincmd x";
              options.desc = "Exchange window";
            }

            {
              key = "<c-w><s-left>";
              action = cmd "wincmd H";
              options = {
                silent = true;
                desc = "Move window to far left";
              };
            }
            {
              key = "<c-w><s-right>";
              action = cmd "wincmd L";
              options = {
                silent = true;
                desc = "Move window to far right";
              };
            }
            {
              key = "<c-w><s-up>";
              action = cmd "wincmd K";
              options = {
                silent = true;
                desc = "Move window to top";
              };
            }
            {
              key = "<c-w><s-down>";
              action = cmd "wincmd J";
              options = {
                silent = true;
                desc = "Move window to bottom";
              };
            }

            # Tabs
            {
              key = "<leader><tab>`";
              action = cmd "tabnext #";
              options.desc = "Other tab";
            }
            {
              key = "<leader><tab>c";
              action = cmd "tabclose";
              options.desc = "Close tab";
            }
            {
              key = "<leader><tab>d";
              action = cmd "tabclose";
              options.desc = "Close tab";
            }
            {
              key = "<leader><tab>n";
              action = cmd "tabnew";
              options.desc = "New tab";
            }

            # Files
            {
              key = "<leader>fC";
              action = function "require('genghis').duplicateFile()";
              options.desc = "Copy file";
            }
            {
              key = "<leader>fD";
              action = function "require('genghis').trashFile()";
              options.desc = "Trash file";
            }
            {
              key = "<leader>fR";
              action = function "require('genghis').moveAndRenameFile()";
              options.desc = "Rename file";
            }
            {
              key = "<leader>fr";
              action = cmd "Telescope oldfiles";
              options.desc = "Search recent files";
            }
            {
              key = "<leader>fs";
              action = cmd "write";
              options.desc = "Save file";
            }
            {
              key = "<leader>fx";
              action = function "require('genghis').chmodx()";
              options.desc = "Set executable bit";
            }
            {
              key = "<leader>fy";
              action = function "require('genghis').copyFilepath()";
              options.desc = "Yank file path";
            }

            # Sessions
            {
              key = "<leader>pa";
              action = cmd "SessionSave";
              options.desc = "Create/save session";
            }
            {
              key = "<leader>pd";
              action = cmd "SessionDelete";
              options.desc = "Delete current session";
            }
            {
              key = "<leader>pP";
              action = cmd "SessionPurgeOrphaned";
              options.desc = "Purge orphaned sessions";
            }
            {
              key = "<leader>pp";
              action = cmd "Telescope session-lens";
              options.desc = "Switch session";
            }

            # Navbuddy
            {
              key = "<leader>cn";
              action = cmd "Navbuddy";
              options.desc = "Navbuddy";
            }

            # Agitator
            {
              key = "<leader>gB";
              action = function "require('agitator').git_blame_toggle()";
              options.desc = "Git blame";
            }
            {
              key = "<leader>gff";
              action = function "require('agitator').open_file_git_branch()";
              options.desc = "Find git file";
            }
            {
              key = "<leader>gf/";
              action = function "require('agitator').search_git_branch()";
              options.desc = "Search in git branch";
            }

            # Neogit
            {
              key = "<leader>gg";
              action = cmd "Neogit";
              options.desc = "Neogit";
            }

            # Format
            {
              key = "<leader>cf";
              action = function "vim.lsp.buf.format()";
              options.desc = "Format buffer/region";
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
              options.desc = "Other buffer";
            }

            # Terminal
            {
              key = "<leader>oT";
              action = cmd ":terminal";
              options.desc = "Open terminal here";
            }
            {
              key = "<leader>ot";
              action = function "require('FTerm').toggle()";
              options.desc = "Open floating terminal";
            }
            {
              key = "<s-esc>";
              action = "<c-\\><c-n>";
              mode = "t";
            }
            {
              key = "<s-bs>";
              action = "<bs>";
              mode = "t";
            }

            # Oil
            {
              key = "<leader>o-";
              action = cmd ":Oil";
              options.desc = "Oil";
            }

            # Hop
            {
              key = "gs/";
              action = cmd ":HopPatternMW";
              mode = "n";
              options.desc = "Hop to pattern";
            }
            {
              key = "gs.";
              action = cmd ":HopAnywhereMW";
              mode = "n";
              options.desc = "Hop anywhere";
            }
            {
              key = "gsl";
              action = cmd ":HopLineMW";
              mode = "n";
              options.desc = "Hop to line";
            }
            {
              key = "gss";
              action = cmd ":HopChar2MW";
              mode = "n";
              options.desc = "Hop to bigram";
            }
            {
              key = "gsw";
              action = cmd ":HopWordMW";
              mode = "n";
              options.desc = "Hop to word";
            }

            # DAP
            {
              key = "<c-cr>";
              action = function "require('dap').toggle_breakpoint()";
              mode = "n";
              options.desc = "Toggle breakpoint";
            }
            {
              key = "<leader>d<up>";
              action = function "require('dap').up()";
              mode = "n";
              options.desc = "Up stacktrace";
            }
            {
              key = "<leader>d<down>";
              action = function "require('dap').down()";
              mode = "n";
              options.desc = "Down stacktrace";
            }
            {
              key = "<leader>d_";
              action = function "require('dap').run_to_cursor()";
              mode = "n";
              options.desc = "Run to cursor";
            }
            {
              key = "<leader>db";
              action = function "require('dap').toggle_breakpoint()";
              mode = "n";
              options.desc = "Toggle breakpoint";
            }
            {
              key = "<leader>dB";
              action = function "require('dap').list_breakpoints()";
              mode = "n";
              options.desc = "List breakpoints";
            }
            {
              key = "<leader>dC";
              action = function "require('dap').clear_breakpoints()";
              mode = "n";
              options.desc = "Clear breakpoints";
            }
            {
              key = "<leader>dd";
              action = function "require('dap').continue()";
              mode = "n";
              options.desc = "Star debugger/Continue execution";
            }
            {
              key = "<leader>dD";
              action = function "require('dap').reverse_continue()";
              mode = "n";
              options.desc = "Reverse continue";
            }
            {
              key = "<leader>de";
              action = function "require('dap').set_exception_breakpoints()";
              mode = "n";
              options.desc = "Set exception breakpoints";
            }
            {
              key = "<leader>df";
              action = function ''
                local widgets = require('dap.ui.widgets')
                widgets.centered_float(widgets.frames)
              '';
              mode = "n";
              options.desc = "Frames";
            }
            {
              key = "<leader>dF";
              action = function "require('dap').restart_frame()";
              mode = "n";
              options.desc = "Frames";
            }
            {
              key = "<leader>dg";
              action = function "require('dap').focus_frame()";
              mode = "n";
              options.desc = "Goto current frame";
            }
            {
              key = "<leader>dh";
              action = function "require('dap.ui.widgets').hover()";
              mode = "n";
              options.desc = "Debugger hover";
            }
            {
              key = "<leader>di";
              action = function "require('dap').step_into()";
              mode = "n";
              options.desc = "Step into";
            }
            {
              key = "<leader>dj";
              action = function "require('dap').down()";
              mode = "n";
              options.desc = "Down stacktrace";
            }
            {
              key = "<leader>dK";
              action = function "require('dap').terminate()";
              mode = "n";
              options.desc = "Terminate debugging session";
            }
            {
              key = "<leader>dk";
              action = function "require('dap').up()";
              mode = "n";
              options.desc = "Up stacktrace";
            }
            {
              key = "<leader>dL";
              action = function "require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))";
              mode = "n";
              options.desc = "Set breakpoint with log";
            }
            {
              key = "<leader>dN";
              action = function "require('dap').step_back()";
              mode = "n";
              options.desc = "Step back";
            }
            {
              key = "<leader>dn";
              action = function "require('dap').step_over()";
              mode = "n";
              options.desc = "Step over";
            }
            {
              key = "<leader>do";
              action = function "require('dap').step_over()";
              mode = "n";
              options.desc = "Step out";
            }
            {
              key = "<leader>dP";
              action = function "require('dap').run_last()";
              mode = "n";
              options.desc = "Run previous config";
            }
            {
              key = "<leader>dp";
              action = function "require('dap.ui.widgets').preview()";
              mode = "n";
              options.desc = "Debugger preview";
            }
            {
              key = "<leader>dR";
              action = function "require('dap').restart()";
              mode = "n";
              options.desc = "Restart debugger";
            }
            {
              key = "<leader>dr";
              action = function "require('dap').repl.toggle()";
              mode = "n";
              options.desc = "Toggle debugger REPL";
            }
            {
              key = "<leader>ds";
              action = function ''
                local widgets = require('dap.ui.widgets')
                widgets.centered_float(widgets.scopes)
              '';
              mode = "n";
              options.desc = "Scopes";
            }
          ];

          opts = {
            background = "dark";
            diffopt = "filler,internal,algorithm:histogram,indent-heuristic,followwrap";
            cursorline = true;
            expandtab = true;
            foldlevel = 99;
            guifont = "Myosevka:h13.0";
            ignorecase = true;
            incsearch = true;
            laststatus = 3;
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
              settings = {
                auto_session = {
                  auto_restore = true;
                  enable_last_session = false;
                  create_enabled = false;
                  use_git_branch = false;
                };
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

            cmp-dap.enable = true;

            cmp-nvim-lsp.enable = true;

            cmp-nvim-lsp-document-symbol.enable = true;

            cmp-nvim-lua.enable = true;

            cmp-omni.enable = true;

            cmp-treesitter.enable = true;

            cmp-zsh.enable = true;

            colorizer.enable = true;

            dap = {
              enable = true;
              extensions.dap-python = {
                inherit (config.lunik1.home.lang.python) enable;
                adapterPythonPath = "python"; # use direnv/virtualenv
              };
            };

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

            hop = {
              enable = true;
              settings.jump_on_sole_occurrence = false;
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
                    options.desc = "Restart LSP";
                  }
                  {
                    key = "<c-k>";
                    action = function "vim.lsp.buf.signature_help()";
                    options.desc = "Show signature help";
                  }
                  {
                    key = "<leader>cd";
                    action = function "vim.lsp.buf.definition()";
                    options.desc = "Jump to definition";
                  }
                  {
                    key = "<leader>cD";
                    action = function "vim.lsp.buf.references()";
                    options.desc = "Jump to references";
                  }
                  {
                    key = "<leader>cr";
                    action = function "vim.lsp.buf.rename()";
                    options.desc = "Rename";
                  }
                  {
                    key = "<leader>ct";
                    action = function "vim.lsp.buf.type_definition()";
                    options.desc = "Jump to type definition";
                  }
                  {
                    key = "<leader>ca";
                    action = function "vim.lsp.buf.code_action()";
                    mode = "n";
                    options.desc = "Execute code action";
                  }
                  {
                    key = "<leader>ca";
                    action = function "vim.lsp.buf.range_code_action()";
                    mode = "v";
                    options.desc = "Execute code action";
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
                clojure_lsp.enable = config.lunik1.home.lang.clojure.enable;
                digestif.enable = true;
                dockerls.enable = true;
                jsonls.enable = config.lunik1.home.lang.data.enable;
                lua_ls.enable = true;
                marksman.enable = true;
                nil_ls = {
                  inherit (config.lunik1.home.lang.nix) enable;
                  settings.formatting.command = [ "nixfmt" ];
                };
                pylsp = {
                  inherit (config.lunik1.home.lang.python) enable;
                  package = null;
                  extraOptions = { };
                  settings.plugins.ruff.enabled = true;
                };
                rust_analyzer = {
                  inherit (config.lunik1.home.lang.rust) enable;
                  installCargo = true;
                  installRustc = true;
                };
                taplo.enable = config.lunik1.home.lang.data.enable;
                typos_lsp.enable = true;
                yamlls.enable = config.lunik1.home.lang.data.enable;
              };
            };

            lspkind = {
              enable = true;
              cmp.enable = true;
            };

            lualine.enable = true;

            oil.enable = true;

            mini = {
              enable = true;
              modules.icons = { };
              mockDevIcons = true;
            };

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
                "_" = "RevertPopup";
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
                  yamlfmt.enable = true;
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

            nvim-lightbulb = {
              enable = true;
              settings = {
                autocmd.enabled = true;
              };
            };

            nvim-surround.enable = true;

            rainbow-delimiters.enable = true;

            telescope = {
              enable = true;
              extensions = {
                fzf-native.enable = true;
              };
            };

            sleuth.enable = true;

            treesitter = {
              enable = true;
              folding = true;
              nixvimInjections = true;
              settings = {
                indent.enable = true;
                incrementalSelection.enable = true;
              };
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

            which-key = {
              enable = true;
              settings.plugins = {
                marks = false;
                registers = false;
              };
            };

            vim-bbye = {
              enable = true;
              keymaps = {
                bdelete = "<leader>bd";
                bwipeout = "<leader>bw";
              };
            };

            vim-matchup = {
              enable = true;
              treesitter.enable = true;
              settings = {
                surround_enabled = 1;
              };
            };
          };

          extraConfigLua = ''
            vim.opt.formatoptions:append { 'o', 'r' }

            vim.diagnostic.config({
              virtual_text = false,
              underline = true,
              update_in_insert = false,
              severity_sort = true,
              float = { source = 'always', border = 'rounded' },
            })

            vim.api.nvim_set_hl(0, 'CursorLine', { bg = '#1d2021' })
            vim.api.nvim_set_hl(0, 'Floatborder', { bg = vim.api.nvim_get_hl_by_name('Normal', true).background })
            vim.api.nvim_set_hl(0, 'NormalFloat', { bg = vim.api.nvim_get_hl_by_name('Normal', true).background })

            vim.api.nvim_set_hl(0, 'Sneak', { fg = '#282828', bg = '#d3869b' })
            vim.api.nvim_set_hl(0, 'SneakScope', { fg = '#282828', bg = '#a89984' })

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

            vim.api.nvim_set_hl(0, 'QuickScopePrimary', { fg = '#fe8019', bold = true, underline = true })
            vim.api.nvim_set_hl(0, 'QuickScopeSecondary', { fg = '#8ec07c', bold = true, underline = true })

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

            require('orgmode').setup({
                mappings = { prefix = '<leader>m' }
            })

            require('pqf').setup()

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

                -- ⌘ mappings for mac
                vim.keymap.set('n', '<D-s>', '<cmd>:w<CR>')
                vim.keymap.set('v', '<D-c>', '"+y')
                vim.keymap.set('n', '<D-v>', '"+P')
                vim.keymap.set('v', '<D-v>', '"+P')
                vim.keymap.set('c', '<D-v>', '<C-r>+')
                vim.keymap.set('i', '<D-v>', '<Esc>l"+Pli')

                -- toggle transparency
                vim.keymap.set('n', '<Leader>tT', toggle_transparency, { desc = "Transparency" })
            end
          '';

          extraPlugins = with pkgs.vimPlugins; [
            agitator
            FTerm-nvim
            nvim-genghis
            nvim-pqf
            orgmode
            plenary-nvim
            project-nvim
            quick-scope
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

      neovide = {
        enable = config.lunik1.home.gui.enable || pkgs.stdenv.isDarwin;
        settings = {
          fork = true;
        };
      };
    };
  };
}
