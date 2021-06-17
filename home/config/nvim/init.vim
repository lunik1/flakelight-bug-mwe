scriptencoding utf-8

filetype plugin indent on

" Skip loading of gui menus
let g:did_install_default_menus = 1
let g:did_install_syntax_menu = 1

" Set leader keys
nnoremap <SPACE> <Nop>
noremap <SPACE> <Nop>
sunmap <SPACE>
let mapleader = "\<SPACE>"
let maplocalleader = "\\"

"" PLUGINS
function! PackagerInit() abort
  packadd vim-packager
  call packager#init({ 'depth': 1 })

  call packager#add('axelf4/vim-strip-trailing-whitespace')
  call packager#add('bakpakin/fennel.vim')
  call packager#add('cespare/vim-toml')
  call packager#add('cohama/lexima.vim')
  call packager#add('gruvbox-community/gruvbox')
  call packager#add('honza/vim-snippets')
  call packager#add('jackguo380/vim-lsp-cxx-highlight')
  call packager#add('jsfaint/coc-neoinclude')
  call packager#add('JuliaEditorSupport/julia-vim')
  call packager#add('justinmk/molokai')
  call packager#add('Konfekt/FastFold')
  call packager#add('kristijanhusak/vim-packager', { 'type': 'opt' })
  call packager#add('LnL7/vim-nix')
  call packager#add('luochen1990/rainbow')  " rainbow parentheses
  call packager#add('mbbill/undotree')
  call packager#add('neoclide/coc-neco')
  call packager#add('neoclide/coc.nvim', { 'branch': 'release' })
  call packager#add('qpkorr/vim-bufkill')  " kill buffers without closing windows
  call packager#add('romainl/vim-qf')
  call packager#add('sheerun/vim-polyglot')
  call packager#add('Shougo/neco-vim')
  call packager#add('Shougo/neoinclude.vim')
  call packager#add('skywind3000/asyncrun.vim')
  call packager#add('skywind3000/asynctasks.vim')
  call packager#add('tmhedberg/SimpylFold', { 'for': 'python' })  " better folding in python files
  call packager#add('tommcdo/vim-exchange')  " add cx{motion} for exchanging
  call packager#add('tommcdo/vim-lion')  " align at charachter
  call packager#add('tomtom/tcomment_vim')  " normal mode maps for manipulating comments
  call packager#add('tpope/vim-abolish')  " abbreviations, :S, and coercion oh my!
  call packager#add('tpope/vim-classpath')  " set path match class path on JVM languages
  call packager#add('tpope/vim-endwise')  " set path match class path on JVM languages
  call packager#add('tpope/vim-repeat')  " better .
  call packager#add('tpope/vim-salve')
  call packager#add('tpope/vim-surround')
  call packager#add('tpope/vim-unimpaired')  " ]b [b etc. mappings
  call packager#add('unblevable/quick-scope')
  call packager#add('vim-airline/vim-airline')  " fancy command line
  call packager#add('vim-scripts/TWiki-Syntax')  " TWiki syntax
  call packager#add('Vimjas/vim-python-pep8-indent')  " better python indent handling
  call packager#add('w0rp/ale')

  " plugins that need vim features
  if has('unix') || has('win32unix') || has('macunix')
    call packager#add('tpope/vim-eunuch')  " UNIX helpers
  endif

  if has('nvim')
    call packager#add('Vigemus/iron.nvim')
      noremap <F12> :IronRepl<CR>
      cabbrev repl IronRepl

    call packager#add('Olical/conjure')
  endif

  if has('python3')
    call packager#add('numirias/semshi', {'do': ':UpdateRemotePlugins'})
  endif

  " plugins that need external commands
  if executable('fzf')
    call packager#add('junegunn/fzf.vim')
  endif

  if executable('git')
    call packager#add('jreybert/vimagit')  " magit in vim

    if has('signs')
     call packager#add('airblade/vim-gitgutter')
    endif
  endif

endfunction

" Load plugins only for specific filetype
" augroup packager_filetype
"   autocmd!
"   autocmd FileType clojure packadd vim-cljfmt
" augroup END

" vim-plug-esque aliases
command! PackagerInstall call PackagerInit() | call packager#install()
command! -bang PackagerUpdate call PackagerInit() | call packager#update({ 'force_hooks': '<bang>' })
command! PackagerClean call PackagerInit() | call packager#clean()
command! PackagerStatus call PackagerInit() | call packager#status()


""  PLUGIN CONFIG
"" gruvbox
let g:gruvbox_contrast_dark = 'hard'
let g:gruvbox_italic = 1

"" lexima.vim
let g:lexima_enable_basic_rules = 0
let g:lexima_enable_endwise_rules = 0

"" ale
let g:ale_disable_lsp = 1

"" asyncrun
let g:asyncrun_open = 10

"" coc
let g:coc_global_extensions = [
      \  'coc-conjure',
      \  'coc-dictionary',
      \  'coc-emoji',
      \  'coc-json',
      \  'coc-markdownlint',
      \  'coc-omni',
      \  'coc-python',
      \  'coc-rust-analyzer',
      \  'coc-snippets',
      \  'coc-syntax',
      \  'coc-tasks',
      \  'coc-texlab',
      \  'coc-vimlsp',
      \  'coc-yaml',
      \  'coc-yank',
      \ ]
set formatexpr=CocAction('formatSelected')

vmap <leader>fo  <Plug>(coc-format-selected)
nmap <leader>fo  <Plug>(coc-format-selected)
vmap <leader>F  :call CocAction('format')<CR>
nmap <leader>F  :call CocAction('format')<CR>
nmap <leader>rn <Plug>(coc-rename)
vmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>qf  <Plug>(coc-fix-current)
nmap <leader>qf  <Plug>(coc-fix-current)
nmap <leader>t  :CocList tasks<CR>

nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

nnoremap <silent> K :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

augroup coc_highlight
  autocmd!
  autocmd CursorHold * silent call CocActionAsync('highlight')
augroup END

command! -nargs=0 Format :call CocAction('format')
command! -nargs=? Fold :call CocAction('fold', <f-args>)
command! -nargs=0 OR   :call CocAction('runCommand', 'editor.action.organizeImport')

" manually trigger completion
inoremap <silent><expr> <c-space> coc#refresh()

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
let g:coc_snippet_prev = '<C-Left>'
let g:coc_snippet_next = '<C-Right>'

"" fzf
let g:fzf_action = {
      \ 'ctrl-t': 'tab split',
      \ 'ctrl-x': 'split',
      \ 'ctrl-s': 'vsplit'
  \ }

vmap <leader>ff :Files<CR>
nmap <leader>ff :Files<CR>
vmap <leader>fg :GFiles<CR>
nmap <leader>fg :GFiles<CR>
vmap <leader>fb :Buffers<CR>
nmap <leader>fb :Buffers<CR>
vmap <leader>fl :Lines<CR>
nmap <leader>fl :Lines<CR>
vmap <leader>f/ :BLines<CR>
nmap <leader>f/ :BLines<CR>
vmap <leader>fh :History<CR>
nmap <leader>fh :History<CR>
vmap <leader>fc :History:<CR>
nmap <leader>fc :History:<CR>

"" quick-scope
" let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']

"" rainbow
let g:rainbow_active = 1

"" undotree
noremap <F6> :UndotreeToggle<CR>

"" vim-airline
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#extensions#tabline#enabled = 1  " and a fancy tab line
let g:airline_powerline_fonts = 1
let g:airline_theme='gruvbox'
let g:airline_section_error = '%{airline#util#wrap(airline#extensions#coc#get_error(),0)}'
let g:airline_section_warning = '%{airline#util#wrap(airline#extensions#coc#get_warning(),0)}'
set laststatus=2

"" iron
if has('nvim')
  noremap <F12> :IronRepl<CR>
  cabbrev repl IronRepl
endif

"" vim-fireplace
let g:clj_fmt_autosave = 0

"" vim-cljfmt
function! CljfmtExpr(start, end)
  silent execute a:start.','.a:end.'CljfmtRange'
endfunction

augroup clojure_set_formatexpr
  autocmd!
  autocmd Filetype clojure setlocal formatexpr=CljfmtExpr()
augroup END

""""""""

behave xterm

" Appearance
set colorcolumn=80
set cursorline
set fillchars=vert:│,fold:―,diff:―
set nowrap
set number
set relativenumber
set scrolloff=5
set sidescrolloff=10
set listchars=tab:▸\ ,eol:¶,precedes:←,extends:→,nbsp:~,trail:•

if has('nvim')
  set inccommand=nosplit
  set pumblend=10
  set winblend=10

  augroup term_open  " no line numbers in terminal windows
    autocmd!
    autocmd TermOpen * setlocal nonumber norelativenumber
  augroup END
endif

" Colours
set background=dark
syntax on
if exists('+termguicolors')
  set termguicolors
endif
colorscheme gruvbox

" Fold settings
set foldmethod=syntax
set foldlevel=99

let g:baan_fold=1
let g:clojure_fold = 1  " may break rainbow-parens plugins
let g:fortran_fold = 1
let g:perl_fold = 1
let g:perl_fold_blocks = 1
let g:php_folding = 1
let g:ruby_fold = 1
let g:sh_fold_enabled = 4
let g:tex_fold_enabled = 1
let g:vimsyn_folding = 'af'
let g:xml_syntax_folding = 1
let g:zsh_fold_enable = 1

" Search settings
set ignorecase
set incsearch
set smartcase

" Tab settings
set autoindent
set expandtab
set shiftwidth=4
set smarttab
set softtabstop=4
set tabstop=4
" per filetype
augroup vim_indent
  autocmd!
  autocmd Filetype vim setlocal tabstop=2 softtabstop=2 shiftwidth=2
augroup END

" Behaviour
set hidden
set lazyredraw
set mouse=a
set nostartofline
set shortmess+=c
set smartcase
set splitbelow
set splitright
set undofile
set updatetime=250
set visualbell t_vb=
if has('nvim')
  set cpoptions+=_  " don't include space after word with cw
endif

if executable('rg')
    set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case
endif

" :bn and :bp ignore quickfix
augroup qf
    autocmd!
    autocmd FileType qf set nobuflisted
augroup END

" Misc
let g:netrw_browsex_viewer='xdg-open'
let g:tex_flavour='latex'
if has('unnamedplus')
  set clipboard=unnamedplus
endif
set pastetoggle=<F11>
set spelllang=en_gb
set shell=zsh

"" Maps and remaps
" ww writes and wipes current buffer
cabbrev ww w<bar>bw
" wd writes and deletes current buffer
cabbrev wd w<bar>bd

" No ex mode
nnoremap Q <Nop>

" Enter creates a new line below, shift+Enter above
nmap <S-Enter> O<Esc>
nmap <CR> o<Esc>

" Disable paste on middle mouse click
map <MiddleMouse> <Nop>
imap <MiddleMouse> <Nop>

" F5 forces a redraw
noremap <F5> :redraw!<cr>

" Y consistent with D, C
noremap Y y$

" Unimpaired-like mapping for tabs
nmap <silent> [<TAB> :tabprevious<CR>
nmap <silent> ]<TAB> :tabnext<CR>
nmap <silent> [<S-TAB> :tabrewind<CR>
nmap <silent> ]<S-TAB> :tablast<CR>

" Turn off search highlights
nnoremap <esc><esc> :noh<return><esc>

" Move windows with arrow keys
nnoremap <silent> <c-w><S-Right> <c-w>L
nnoremap <silent> <c-w><S-Left> <c-w>H
nnoremap <silent> <c-w><S-Up> <c-w>K
nnoremap <silent> <c-w><S-Down> <c-w>J

" Terminal
if has('nvim')
  tnoremap <Esc> <C-\><C-n>
  tnoremap <expr> <C-v> '<C-\><C-N>pi'
endif

" Custom digraphs
if has('multi_byte')
  digraph
        \ *e 01013
        \ *f 00982
        \ *h 00977
        \ *r 01009
        \ h- 08463
endif

" Custom functions
" Automatically insert header guards
function! s:insert_gates() abort
  let l:gatename = substitute(toupper(expand('%:t')), '\\.', '_', 'g')
  execute 'normal! i#ifndef ' . l:gatename
  execute 'normal! o#define ' . l:gatename
  execute 'normal! o'
  execute 'normal! o'
  execute 'normal! Go#endif /* ' . l:gatename . ' */'
  normal! kk
endfunction
augroup filetype_header
  autocmd!
  autocmd BufNewFile *.{h,hh,hxx,hpp} call <SID>insert_gates()
augroup END
