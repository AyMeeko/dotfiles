" Powered by vim-plug
" https://github.com/junegunn/vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

autocmd VimEnter * hi Normal ctermbg=NONE

function! StatusLine(current, width)
  let l:s = ''

  if a:current
    let l:s .= crystalline#mode() . crystalline#right_mode_sep('')
  else
    let l:s .= '%#CrystallineInactive#'
  endif
  let l:s .= ' %f%h%w%m%r '
  if a:current
    let l:s .= crystalline#right_sep('', 'Fill') . ' %{FugitiveHead()}'
  endif

  let l:s .= '%='
  if a:current
    let l:s .= crystalline#left_sep('', 'Fill') . ' %{&paste ?"PASTE ":""}%{&spell?"SPELL ":""}'
    let l:s .= crystalline#left_mode_sep('')
  endif
  if a:width > 80
    let l:s .= ' %{&ft}[%{&fenc!=#""?&fenc:&enc}][%{&ff}] %l/%L %c%V %P '
  else
    let l:s .= ' '
  endif

  return l:s
endfunction

function! TabLine()
  let l:vimlabel = has('nvim') ?  ' NVIM ' : ' VIM '
  return crystalline#bufferline(2, len(l:vimlabel), 1) . '%=%#CrystallineTab# ' . l:vimlabel
endfunction

let g:crystalline_enable_sep = 1
let g:crystalline_statusline_fn = 'StatusLine'
let g:crystalline_tabline_fn = 'TabLine'
let g:crystalline_theme = 'onedark'

set showtabline=2
set guioptions-=e
set laststatus=2

call plug#begin('~/.vim/plugged')
Plug  'dstein64/vim-startuptime', { 'on': 'StartupTime' }
" Sequence Diagramming Tool
"Plug 'scrooloose/vim-slumlord'
"Plug 'aklt/plantuml-syntax'
" LSP + Linting
Plug 'dense-analysis/ale', { 'on': '<Plug>(ale_go_to_definition)' }
" status/tabline for vim
Plug 'rbong/vim-crystalline'
" Fuzzy file, buffer, mru, tag, etc finder
"Plug 'ctrlpvim/ctrlp.vim'
"Plug 'FelikZ/ctrlp-py-matcher'
" ack.vim alternative
Plug 'dyng/ctrlsf.vim', { 'on': '<Plug>CtrlSFPrompt' }
" git wrapper
Plug 'tpope/vim-fugitive'
" git diff in gutter
Plug 'airblade/vim-gitgutter'
Plug 'mg979/vim-visual-multi'
" Fast commenting
Plug 'scrooloose/nerdcommenter'
" Tree explorer
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
" Syntax highlighting for multiple languages
Plug 'Vimjas/vim-python-pep8-indent'
Plug 'vim-scripts/indentpython.vim'
" Rainbow parends
Plug 'luochen1990/rainbow', { 'on': 'RainbowToggle' }
" Enable repeating supported plugin maps
Plug 'tpope/vim-repeat'
" Easily add/delete/change 'surroundings'
Plug 'tpope/vim-surround'
" Run pytest in tmux pane
Plug 'vim-test/vim-test', { 'on': ['TestNearest', 'TestFile'] }
" Allow vim to send commands to tmux
Plug 'preservim/vimux', { 'on': ['TestNearest', 'TestFile'] }
Plug 'tpope/vim-unimpaired'
" Pipe cursor in insert mode, block in normal mode
Plug 'sjl/vitality.vim'
" Toggle between one window and multi-window vim splits
Plug 'itspriddle/ZoomWin', { 'on': 'ZoomWin' }

" Vim, iterm, and tmux colors
Plug 'edkolev/tmuxline.vim', { 'on': ['Tmuxline', 'TmuxlineSnapshot'] }
Plug 'romainl/Apprentice'
" Python
Plug 'Konfekt/FastFold'
Plug 'Einenlum/yaml-revealer'
Plug 'stephpy/vim-yaml'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
call plug#end()

" ================================================================================================
"                                       GENERIC VIM SETTINGS
" ================================================================================================
"
" Python
" proper PEP8 indentation
au BufNewFile, BufRead *.py
    \ set tabstop=4
    \ set softtabstop=4
    \ set shiftwidth=4
    \ set textwidth=79
    \ set expandtab
    \ set autoindent
    \ set fileformat=unix
let python_highlight_all=1
set foldmethod=indent
set foldnestmax=2
set foldlevel=20
nnoremap <space> za
vnoremap <space> zf

""
"" Basic Setup
""
"au BufWritePost *.c,*.cpp,*.h silent! !ctags -R &
colorscheme apprentice
set termguicolors
let mapleader = ","    	" Set leader to , instead of \
set nocompatible       	" Use vim, no vi defaults
set number             	" Show line numbers
set ruler              	" Show line and column number
syntax enable          	" Turn on syntax highlighting allowing local overrides
set encoding=utf-8     	" Set default encoding to UTF-8
set mouse=a 	       	  " turn on the mouse
set hidden 	       	    " Be able to close/hide buffers without saving them
set noshowmode  	      " Hide the default mode text (e.g. -- INSERT -- below the statusline)
set laststatus=2        " Always display the statusline in all windows
set title
set shell=$ZSH_PATH
filetype plugin indent on
filetype plugin on
set updatetime=250
syntax on
set colorcolumn=100
set tagrelative
set tags^=./.git/tags

" Switch to last buffer
function SwitchBuffer()
  b#
endfunction
nmap <space><Tab> :call SwitchBuffer()<CR>

function ToggleFoldMethod()
  if &foldmethod == "indent"
    echo "foldmethod=manual"
    set foldmethod=manual
    return
  endif
  if &foldmethod == "manual"
    echo "foldmethod=indent"
    set foldmethod=indent
  endif
endfunction
nmap <Leader><Tab> :call ToggleFoldMethod()<CR>

function CopyLine()
  normal ^v$h"*y
endfunction
nmap <Leader>cy :call CopyLine()<CR>

" Fix yank and paste in tmux
if $TMUX == ''
  set clipboard+=unnamed
endif

" Lets you sudo a file after opening
cmap w!! w !sudo tee % >/dev/null

" In ruby, use % to find a 'do's 'end'
runtime! macros/matchit.vim

" Find non-ascii characters
highlight nonascii guibg=Red ctermbg=1 term=standout
au BufReadPost * syntax match nonascii "[^\u0000-\u007F]"

""
"" Whitespace
""

set wrap 			                    " wrap lines
set tabstop=2                     " a tab is two spaces
set shiftwidth=2                  " an autoindent (with <<) is two spaces
set expandtab                     " use spaces, not tabs
set list                          " Show invisible characters
set backspace=indent,eol,start    " backspace through everything in insert mode

" List chars
set listchars=""                  " Reset the listchars
set listchars=tab:\ \             " a tab should display as "  ", trailing whitespace as "."
set listchars+=trail:.            " show trailing spaces as dots
set listchars+=extends:>          " The character to show in the last column when wrap is
                                  " off and the line continues beyond the right of the screen
set listchars+=precedes:<         " The character to show in the last column when wrap is
                                  " off and the line continues beyond the left of the screen
""
"" Searching
""

set hlsearch    " highlight matches
set incsearch   " incremental searching
set ignorecase  " searches are case insensitive...
set smartcase   " ... unless they contain at least one capital letter



" ================================================================================================
"                                       MAKE MY LIFE EASIER
" ================================================================================================

" fold {} or def/end or do/end
" relies on runtime! macros/matchit.vim
function! Fold()
  if (foldclosed(line('.')) > 0)
    normal zo
    return
  end

  let line = getline('.')
  let brace = matchstr(line, '[{}]')
  let contains_do = match(line, 'do') != -1
  let contains_def = match(line, 'def') != -1
  let contains_end = match(line, 'end') != -1

  if (brace != '')
    if (brace == '{')
      normal 0vf{%zf
    else
      normal 0v%zf
    end
  elseif (contains_do)
    normal 0v$%zf
  elseif (contains_def || contains_end)
    normal 0v%zf
  end
endfunction

"nnoremap <silent><space> :call Fold()<CR>

" Clear last search
nmap <silent> ,/ :nohlsearch<CR>

" Makes cursor not jump 'over' a line if it's wrapped to a second line
nnoremap <expr> k (v:count == 0 ? 'gk' : 'k')
nnoremap <expr> j (v:count == 0 ? 'gj' : 'j')

" Ctrl h and l to change buffers
nnoremap <C-l> :tabn<CR>
nnoremap <C-h> :tabp<CR>

" make command line work with emacs style editing
cnoremap <C-a>  <Home>
cnoremap <C-b>  <Left>
cnoremap <C-f>  <Right>
cnoremap <C-d>  <Delete>
cnoremap <M-b>  <S-Left>
cnoremap <M-f>  <S-Right>
cnoremap <M-d>  <S-right><Delete>
cnoremap <Esc>b <S-Left>
cnoremap <Esc>f <S-Right>
cnoremap <Esc>d <S-right><Delete>
cnoremap <C-g>  <C-c>

" Allow variations of wq and qa
:ca WQ wq
:ca W w
:ca Wq wq
:ca Q q
:ca Qa qa

" Remove the Windows ^M - when the encodings gets messed up
noremap <Leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

" highlight non ascii characters
highlight nonascii guibg=Red ctermbg=1 term=standout
au BufReadPost * syntax match nonascii "[^\u0000-\u007F]"

" Format JSON
nmap <silent> <leader>fj :%!python -m json.tool<CR>

" ================================================================================================
"                                       STOLEN FROM JANUS
" ================================================================================================

" find merge conflict markers
nmap <silent> <leader>fc <ESC>/\v^[<=>]{7}( .*\|$)<CR>

" Bubble single lines -- relies on Unimpaired plugin
nmap <C-k> [e
nmap <C-j> ]e

" Bubble multiple lines -- relies on Unimpaired plugin
vmap <C-k> [egv
vmap <C-j> ]egv

" ================================================================================================
"                                       COLOR SETTINGS
" ================================================================================================

" vim-airline powerline fonts
set guifont=Source\ Code\ Pro\ for\ Powerline:h12
syntax enable
set background=dark

" ================================================================================================
"                                       PLUGIN SETTINGS
" ================================================================================================

" ================================== Airline =====================================================
"let g:airline_theme="lucius"
"let g:airline_powerline_fonts=1
"let g:airline#extensions#tabline#fnamemod = ':t'
"let g:airline#extensions#tmuxline#enabled = 0

" change from insert to normal instantly
if ! has('gui_running')
  set ttimeoutlen=10
  augroup FastEscape
    autocmd!
    au InsertEnter * set timeoutlen=0
    au InsertLeave * set timeoutlen=1000
  augroup END
endif

" ================================== ALE =====================================================
let g:ale_linters = {'python': ['flake8', 'pylint', 'pylsp'], 'zsh': ['shell']}
let g:ale_fixers = {'*': ['remove_trailing_lines', 'trim_whitespace']}
let g:ale_fix_on_save = 1
let g:ale_completion_enabled = 1
let g:ale_default_navigation = 'tab'
nmap <C-F>d <Plug>(ale_go_to_definition)
nmap <C-F>r <Plug>(ale_find_references)
"let g:ale_python_pylsp_config = {
      "\ 'pylsp': {
      "\   'configurationSources': ['flake8'],
      "\   'plugins': {
      "\     'pylint': {'enabled': v:false},
      "\     'flake8': {'enabled': v:false},
      "\     'pycodestyle': {'enabled': v:false}
      "\ }}}
inoremap <silent><expr> <Tab>
      \ pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <silent><expr> <S-Tab>
      \ pumvisible() ? "\<C-p>" : "\<S-TAB>"

" ================================== Better Whitespace ===========================================
hi ExtraWhitespace ctermbg=237

" ================================== CtrlP =======================================================
"let g:ctrlp_match_func = { 'match': 'pymatcher#PyMatch' }
"" Use ripgrep for initial file load
"let g:ctrlp_user_command = 'rg %s --files --color=never --glob ""'
"set wildignore+=*/tmp/*,*.so,*.swp,*.zip
"nmap <Leader>b :CtrlPBuffer<CR>
"let g:ctrlp_show_hidden = 1
"let g:ctrlp_map = '<C-p>'
"let g:ctrlp_custom_ignore = {
"  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
"  \ 'file': '\.pyc$\|\.pyo$\|\.rbc$|\.rbo$\|\.class$\|\.o$\|\~$\',
"  \ }

" ================================== Fzf =======================================================
nmap <C-p> :Files<CR>
nmap <leader>b :Buffer<CR>

" ================================== CtrlSF =======================================================
let g:ctrlsf_position = 'bottom'
let g:ctrlsf_winsize = '25%'
let g:ctrlsf_case_sensitive = 'smart'
let g:ctrlsf_default_root = 'project'
let g:ctrlsf_ackprg = $RG_PATH
nmap     <C-F>f <Plug>CtrlSFPrompt
vmap     <C-F>f <Plug>CtrlSFVwordPath
vmap     <C-F>F <Plug>CtrlSFVwordExec
nmap     <C-F>n <Plug>CtrlSFCwordPath
nmap     <C-F>p <Plug>CtrlSFPwordPath
nnoremap <C-F>o :CtrlSFOpen<CR>
nnoremap <C-F>t :CtrlSFToggle<CR>
inoremap <C-F>t <Esc>:CtrlSFToggle<CR>

" ================================== Fugitive ====================================================
nmap <Leader>gb :Git blame<CR>
nmap <Leader>gs :Git<CR>
nmap <Leader>gd :Gvdiffsplit<CR>

" ================================== Gitgutter ===================================================
nnoremap <Leader>gg :GitGutterLineHighlightsToggle<CR>
nmap <Leader>ha <Plug>(GitGutterStageHunk)
nmap <Leader>hu <Plug>(GitGutterRevertHunk)
nmap <Leader>hp <Plug>(GitGutterPreviewHunk)

" ================================== NERDTree ====================================================
" toggle NERDTree in every tab
map <Leader>n :NERDTreeToggle<CR> :NERDTreeMirror<CR>

" find current file in NERDTree
map <Leader>f<Space> :NERDTreeFind<CR>

let NERDTreeIgnore=['\.pyc$', '\.pyo$', '\.rbc$', '\.rbo$', '\.class$', '\.o$', '\~$']

" close the window if the last thing is a NERDTree
"autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif |

"autocmd vimenter * if !argc() | NERDTree | endif |
if !argc()
  " open a NERDTree if no file was specified
  autocmd vimenter * view ~/.nerdtree | NERDTreeToggle | execute "normal \<S-a>"
else
  " open filler nerdtree file | toggle nerdtree | trigger Shift+A | move tab to
  " left-most position | focus on second tab
  augroup enter
    autocmd vimenter * tab sview ~/.nerdtree | NERDTreeToggle | execute "normal \<S-a>" | tabm 0 | tabn
    "call feedkeys("\<C-h>\<C-l>")
  augroup END
endif

" ================================== Rainbow Parentheses =========================================
let g:rainbow_active = 0
nnoremap <Leader>rp :RainbowToggle<CR>
" blue (21), orange(166), green(34), red(196), purple(93)
let g:rainbow_conf = {
    \   'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick'],
    \   'ctermfgs': ['21', '166', '34', '196', '93'],
    \   'operators': '_,_',
    \   'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/{/ end=/}/ fold'],
    \   'separately': {
    \       '*': {},
    \       'tex': {
    \           'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/'],
    \       },
    \       'lisp': {
    \           'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick', 'darkorchid3'],
    \       },
    \       'vim': {
    \           'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/', 'start=/{/ end=/}/ fold', 'start=/(/ end=/)/ containedin=vimFuncBody', 'start=/\[/ end=/\]/ containedin=vimFuncBody', 'start=/{/ end=/}/ fold containedin=vimFuncBody'],
    \       },
    \       'html': {
    \           'parentheses': ['start=/\v\<((area|base|br|col|embed|hr|img|input|keygen|link|menuitem|meta|param|source|track|wbr)[ >])@!\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'|[^ '."'".'"><=`]*))?)*\>/ end=#</\z1># fold'],
    \       },
    \       'css': 0,
    \   }
    \}

" ================================== Rainbow Levels =========================================
nnoremap <Leader>rl :RainbowLevelsToggle<CR>
let g:rainbow_levels = [
    \{'ctermbg': 'none'},
    \{'ctermbg': 'none'},
    \{'ctermbg': 'none'},
    \{'ctermbg': 'none'},
    \
    \{'ctermbg': 3,   'guibg': '#ffc66d'},
    \{'ctermbg': 9,   'guibg': '#cc7833'},
    \{'ctermbg': 1,   'guibg': '#da4939'},
    \{'ctermbg': 160, 'guibg': '#870000'}]

" ================================== Tmuxline ====================================================
let g:tmuxline_preset = {
      \'a'       : '#S',
      \'win'     : '#I #W',
      \'cwin'    : ['#I', '#W'],
      \'z'       : '%m-%d-%y %I:%M %p',
      \'options' : {'status-justify' : 'left', 'pane-border-fg' : 'colour235', 'pane-active-border-fg' : 'colour235' } }

" ================================== Apprentice Tmuxline Theme
"let g:tmuxline_theme = {
"    \ 'a'    : [ '16', '254' ],
"    \ 'b'    : [ '16', '254' ],
"    \ 'c'    : [ '16', '254' ],
"    \ 'x'    : [ '16', '254' ],
"    \ 'y'    : [ '16', '254' ],
"    \ 'z'    : [ '236', '249' ],
"    \ 'bg'   : [ '247', '234' ],
"    \ 'win'  : [ '245', '236' ],
"    \ 'cwin' : [ '236', '249' ] }

" ================================== ZoomWin =====================================================
map <Leader>zw :ZoomWin<CR>

" tags
packloadall
silent! helptags ALL

" ================================== Vim-Test =====================================================
let test#strategy = "vimux"
let test#python#pytest#executable = 'pytest'
nmap <silent> <Leader>rt :TestNearest<CR>
nmap <silent> <Leader>rf :TestFile<CR>
