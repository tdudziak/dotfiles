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

if v:progname =~? "gvim"
    set background=light
    colorscheme solarized
    set guioptions-=m
    set guioptions-=T
endif

" Warn about trailing whitespace and tabs.
highlight WhitespaceFauxPas ctermbg=Red guibg=tomato
let g:tab_warn_match = matchadd("WhitespaceFauxPas", "\t")

function! DisableTabHighlightsOnCFiles()
    if &filetype == 'c'
        call matchdelete(g:tab_warn_match)
    else
        "let g:tab_warn_match = matchadd("WhitespaceFauxPas", "\t")
    endif
endfunction

augroup vimrc_autocmds
autocmd!

autocmd BufEnter * call DisableTabHighlightsOnCFiles()
autocmd FileType c setlocal noexpandtab

" Highlight trailing whitespace when outside mode.
let trailspace_match = matchadd("WhitespaceFauxPas", "\\s\\+$")
autocmd InsertLeave * let trailspace_match = matchadd("WhitespaceFauxPas", "\\s\\+$")
autocmd InsertEnter * call matchdelete(trailspace_match)

" Mark 80 and 100 column.
set colorcolumn=80,100

" Keyword lookup on Shift-K with Hoogle
autocmd FileType haskell setlocal keywordprg=hoogle
autocmd FileType lhaskell setlocal keywordprg=hoogle
