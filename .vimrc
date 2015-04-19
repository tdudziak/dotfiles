" Basics {{{
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set history=50          " keep 50 lines of command line history
set ruler               " show the cursor position all the time
set showcmd             " display incomplete commands
set incsearch           " do incremental searching
set hlsearch
set autoindent
set relativenumber
set showmatch
set mouse=a
syntax on

" Ignore case on search unless I typed a capital letter explicitly.
set ignorecase
set smartcase

set exrc            " enable per-directory .vimrc files
set secure          " disable unsafe commands in local .vimrc files
" }}}

" Vundle setup and plugins {{{
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'gmarik/Vundle.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'kien/ctrlp.vim'
Plugin 'altercation/vim-colors-solarized.git'
Plugin 'justincampbell/vim-railscasts'
call vundle#end()
filetype plugin indent on
" }}}

" YouCompleteMe setup {{{
" use the Debian package
set rtp+=/usr/share/vim-youcompleteme/
let g:ycm_auto_trigger=0
let g:ycm_enable_diagnostic_signs=0
" }}}

if has('gui_running') " {{{
    colorscheme railscasts
    set guioptions-=m
    set guioptions-=T
    set guifont=DejaVu\ Sans\ Mono\ 10
endif " }}}

" Tabs and indentation setup {{{
" default to Python standard
set tabstop=4
set shiftwidth=4
set expandtab

" Sometimes we want old-school tabs (like in the Linux Kernel coding style)
function! SetOldSchoolTabs()
    setlocal noexpandtab
    setlocal tabstop=8
    setlocal shiftwidth=8
endfunction
" Enable old-school tabs for C
autocmd FileType c call SetOldSchoolTabs()
" }}}

" Fold helper for C an C++ {{{
"
" Rather than using foldmethod=syntax, folds are created manually according to
" certian rules.

python <<endpython
def create_c_folds():
    import vim
    vim.command('set foldmethod=manual')
    vim.command('normal zE') # eliminate all folds
    win = vim.current.window

    show_next = True
    to_show = []
    for (i, line) in enumerate(vim.current.buffer):
        if line.strip() == '{':
            pos = (i+1, line.find('{')+1)
            win.cursor = pos
            vim.command('normal zf%zo')
            if show_next:
                to_show.append(pos)

        if 'namespace' in line or 'class' in line or 'struct' in line:
            show_next = True
        else:
            show_next = False

    # fold everything
    vim.command('normal zM')

    # unfold folds in `to_show'
    for pos in to_show:
        win.cursor = pos
        vim.command('normal zo')

    # go to the first line
    # TODO: attempt to restore previous position and scroll state
    vim.command('normal gg')
endpython
" }}}

python <<endpython
def toggle_c_ptr():
    import vim
    (_, i) = vim.current.window.cursor
    line = vim.current.line

    try:
        for (a,b) in [(i,i+2), (i-1,i+1)]:
            if line[a:b] == '->':
                vim.current.line = line[:a] + '.' + line[b:]
    except IndexError:
        pass

    try:
        if line[i] == '.':
            vim.current.line = line[:i] + '->' + line[i+1:]
    except IndexError:
        pass
endpython

" Trailing whitespace marking {{{
if has('gui_running')
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

    autocmd BufWinEnter * call WhitespaceFauxPasEnable()
    autocmd InsertLeave * call WhitespaceFauxPasEnable()
    autocmd InsertEnter * call WhitespaceFauxPasDisable()
else
    set listchars=trail:-
    set list
endif
" }}}

" Normal mode mappings {{{
" Muscle memory from web browsers
noremap <C-T> :tabnew<Enter>

let mapleader = ","
noremap <silent> <leader><cr> :noh<cr>
noremap <silent> <leader>s :set invspell<cr>

nnoremap <silent> <Leader>z :python create_c_folds()<Cr>

" clang-format (use the one with llvm 3.5.0) not the system default
noremap <Leader>f :pyf /home/tdudziak/llvm/3.5.0/clang-format.py<Cr>
noremap <Leader>F :%pyf /home/tdudziak/llvm/3.5.0/clang-format.py<Cr>
noremap <silent> <Leader>K :YcmCompleter GoToDefinition<Cr>
noremap <silent> <Leader>p :python toggle_c_ptr()<Cr>
" }}}

" Enable spell checking by default on git commits.
autocmd FileType gitcommit setlocal spell

" Mark 80 and 100 column.
set colorcolumn=80,100
highlight ColorColumn ctermbg=Black

" vim:set foldmethod=marker:
