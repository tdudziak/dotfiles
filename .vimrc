" No need for vi compatibility...
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set history=50          " keep 50 lines of command line history
set ruler               " show the cursor position all the time
set showcmd             " display incomplete commands
set incsearch           " do incremental searching
set hlsearch
set autoindent
set number
set showmatch

" Ignore case on search unless I typed a capital letter explicitly.
set ignorecase
set smartcase

syntax on

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

filetype plugin indent on

" This seems to be the most widely chosen combination (and standard in Python).
set tabstop=4
set shiftwidth=4
set expandtab

" Muscle memory from web browser
map <C-T> :tabnew<Enter>

let mapleader = ","
map <silent> <leader><cr> :noh<cr>
map <silent> <leader>s :set invspell<cr>
map <silent> <leader>n :set invnu<cr>

if has('gui_running')
    set background=light
    colorscheme solarized
    set guioptions-=m
    set guioptions-=T
endif

augroup vimrc_autocmds
autocmd!

" Sometimes we want old-school tabs.
function! SetOldSchoolTabs()
    setlocal noexpandtab
    setlocal tabstop=8
    setlocal shiftwidth=8
endfunction
autocmd FileType c\|\(go\) call SetOldSchoolTabs()

" Highlight trailing whitespace when outside insert mode.
highlight WhitespaceFauxPas ctermbg=Red guibg=tomato

function! WhitespaceFauxPasEnable()
    if !exists('w:trailspace_match')
        let w:trailspace_match = matchadd("WhitespaceFauxPas", "\\s\\+$")
    endif
endfunction

function! WhitespaceFauxPasDisable()
    if exists('w:trailspace_match')
        call matchdelete(w:trailspace_match)
        unlet w:trailspace_match
    endif
endfunction

if has('gui_running')
    autocmd WinEnter    * call WhitespaceFauxPasEnable()
    autocmd InsertLeave * call WhitespaceFauxPasEnable()
    autocmd InsertEnter * call WhitespaceFauxPasDisable()
endif

" Enable spell checking by default on git commits.
autocmd FileType gitcommit setlocal spell

" Mark 80 and 100 column.
set colorcolumn=80,100
highlight ColorColumn ctermbg=Black

" Keyword lookup on Shift-K with Hoogle
autocmd FileType haskell setlocal keywordprg=hoogle\ --info
autocmd FileType lhaskell setlocal keywordprg=hoogle\ --info

" Include Go stuff (syntax, filetype, ...)
set rtp+=$GOROOT/misc/vim
autocmd BufReadPre,BufNewFile *.go set filetype=go fileencoding=utf-8 fileencodings=utf-8

set cmdheight=2
