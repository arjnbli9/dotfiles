" --- Bootstrap vim-plug ---
let s:plug_path = expand('~/.vim/autoload/plug.vim')
if empty(glob(s:plug_path))
  silent execute '!curl -fLo ' . s:plug_path . ' --create-dirs '
    \ . 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

syntax enable

" --- Fix terminal background bleed-through ---
augroup FixBackground
  autocmd!
  autocmd ColorScheme * highlight Normal      ctermbg=NONE guibg=NONE
  autocmd ColorScheme * highlight NonText     ctermbg=NONE guibg=NONE
  autocmd ColorScheme * highlight LineNr      ctermbg=NONE guibg=NONE
  autocmd ColorScheme * highlight SignColumn  ctermbg=NONE guibg=NONE
augroup END

" --- Go syntax color overrides (Zed-like) ---
augroup GoHighlights
  autocmd!
  " Method calls (fmt.Println) green, matching function declarations
  autocmd ColorScheme * highlight! link goFunctionCall goFunction
  " Struct fields (os.Args) as plain identifiers
  autocmd ColorScheme * highlight! link goField Normal
  " 'case' rendered as a keyword (red), like 'func' and 'if'
  autocmd ColorScheme * highlight! link goLabel Keyword
augroup END

" --- Filetype-specific ---
augroup GoSettings
  autocmd!
  autocmd FileType go setlocal noexpandtab tabstop=4 shiftwidth=4
augroup END

" --- General settings ---
set nocompatible
set clipboard=unnamed,unnamedplus
set expandtab
set autoindent
set tabstop=4 softtabstop=4
set shiftwidth=4
set scrolloff=16
set number relativenumber
set showmatch
set incsearch
set ignorecase
set smartcase
set termguicolors

" --- Plugins ---
" Disable polyglot for Go (vim-go handles it) and yaml (avoids known quirks)
let g:polyglot_disabled = ['yaml', 'go']

call plug#begin('~/.vim/plugged')
Plug 'sheerun/vim-polyglot'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'sainnhe/sonokai'
Plug 'jiangmiao/auto-pairs'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
call plug#end()

" --- Colorscheme ---
let g:sonokai_style = 'shusia'
let g:sonokai_better_performance = 1
colorscheme sonokai

" --- Leader mappings ---
let mapleader = " "
nnoremap <leader>pv :Vex<CR>
nnoremap <leader><CR> :so ~/.vimrc<CR>
nnoremap <C-p> :GFiles<CR>
nnoremap <leader>pf :Files<CR>

" --- Go highlighting ---
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_operators = 1
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_extra_types = 1
