behave xterm

"" Appearance
set breakindent
set colorcolumn=80
set cursorline
set fillchars=vert:│,fold:―,diff:―
set listchars=tab:▸\ ,eol:¶,precedes:←,extends:→,nbsp:~,trail:•
set nowrap
set number
set pumblend=10
set relativenumber
set scrolloff=5
set sidescrolloff=10
set signcolumn=yes
set winblend=10

" Highlight yanks
augroup YankHighlight
  autocmd!
  autocmd TextYankPost * silent! lua vim.highlight.on_yank {higroup="IncSearch", timeout=150, on_visual=true}
augroup end


"" Behaviour
set clipboard=unnamedplus
set cpoptions+=_ " don't include space after word with cw
set diffopt=filler,internal,algorithm:histogram,indent-heuristic
set expandtab
set foldlevel=99
set ignorecase
set incsearch
set lazyredraw
set mouse=a
set shiftwidth=4
set smartcase
set softtabstop=4
set spelllang=en_gb
set splitbelow
set splitright
set tabstop=4
set undofile
set updatetime=250
set visualbell t_vb=

let g:netrw_browsex_viewer='xdg-open'
let g:tex_flavour='latex'

if executable('rg')
    set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case
endif

"" Maps

" SPC as leader
nnoremap <SPACE> <Nop>
noremap <SPACE> <Nop>
sunmap <SPACE>
map <Space> <Leader>

" No ex
nnoremap Q <Nop>

" Create blank lines with CR
nmap <S-Enter> O<Esc>
nmap <CR> o<Esc>

" Clear search highlight with esc
nnoremap <silent><esc> :noh<cr><esc>
" nnoremap <esc>^[ <esc>^[

" Move windows with arrow keys
nnoremap <silent> <c-w><S-Right> <c-w>L
nnoremap <silent> <c-w><S-Left> <c-w>H
nnoremap <silent> <c-w><S-Up> <c-w>K
nnoremap <silent> <c-w><S-Down> <c-w>J

"" Unimpaired-lite
" buffers
nnoremap <silent> ]b :<c-u>execute 'bnext' . v:count1<cr>
nnoremap <silent> [b :<c-u>execute 'bprevious' . v:count1<cr>
nnoremap <silent> ]B :blast<cr>
nnoremap <silent> [B :bfirst<cr>

" tabs
nnoremap <silent> ]<TAB> :<c-u>execute 'tabnext' . v:count1<cr>
nnoremap <silent> [<TAB> :<c-u>execute 'tabprevious' . v:count1<cr>
nmap <silent> [<S-TAB> :tabfirst<CR>
nmap <silent> ]<S-TAB> :tablast<CR>

" quickfix
nnoremap <silent> ]q :<c-u>execute 'cnext' . v:count1<cr>
nnoremap <silent> [q :<c-u>execute 'cprevious' . v:count1<cr>
nnoremap <silent> ]Q :clast<cr>
nnoremap <silent> [Q :cfirst<cr>

" diagnostics
lua << EOF
    local opts = { noremap = true, silent = true }
    vim.keymap.set('n', '<leader>ce', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
    vim.keymap.set('n', '[e', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
    vim.keymap.set('n', ']e', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
    vim.keymap.set('n', '<leader>cx', '<cmd>lua vim.diagnostic.set_loclist()<CR>', opts)
EOF

if has('multi_byte')
  digraph
        \ *e 01013
        \ *f 00982
        \ *h 00977
        \ *r 01009
        \ h- 08463
endif

"" Toggles
nnoremap <silent> <leader>tl :setlocal list!<cr>
nnoremap <silent> <leader>ts :setlocal spell!<cr>
nnoremap <silent> <leader>tw :setlocal wrap!<cr>
