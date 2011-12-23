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
call matchadd("WhitespaceFauxPas", "\t")
call matchadd("WhitespaceFauxPas", "\\s\\+$")

" Mark 80 and 100 column.
set colorcolumn=80,100

" Keyword lookup on Shift-K with Hoogle
autocmd FileType haskell set keywordprg=hoogle
autocmd FileType lhaskell set keywordprg=hoogle
