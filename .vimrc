" Leader-key shortcuts:
"
"     f       clang-format: local
"     F       clang-format: whole buffer
"     K       YCM: declaration/documentation in preview window
"     p       close the preview window
"     s       toggle spellchecker
"     z       set up custom C/C++ folds
"     Enter   clear search highlighting
"
"
"

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
Plugin 'phleet/vim-mercenary'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'rust-lang/rust.vim'
" Plugin 'Valloric/YouCompleteMe'
Plugin 'vim-scripts/darktango.vim'
Plugin 'justincampbell/vim-railscasts'
Plugin 'altercation/vim-colors-solarized.git'
call vundle#end()
filetype plugin indent on
" }}}

" Ctrl-P setup {{{
let g:ctrlp_switch_buffer = '0'
let g:ctrlp_custom_ignore = '\v[\/](\.git|\.hg|\.svn|build|doc)$'
set wildignore=*~

if executable('ag')
  " Use Ag over Grep
  set grepprg=ag\ --nogroup\ --nocolor

  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
endif
" }}}

" YouCompleteMe setup {{{
let g:ycm_auto_trigger=0
let g:ycm_enable_diagnostic_signs=0
let g:ycm_autoclose_preview_window_after_insertion=1
let g:ycm_show_diagnostics_ui=0
" }}}

if has('gui_running') " {{{
    colorscheme railscasts
    set guioptions-=T
    set guioptions-=m
    set guioptions+=c
    set guifont=Inconsolata\ Medium\ 10
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
" autocmd FileType c call SetOldSchoolTabs()
" }}}

" Fold helper for C an C++ {{{
"
" Rather than using foldmethod=syntax, manual-mode folds are created according
" to certian rules.

python3 <<endpython
def create_c_folds():
    import vim
    KEYWORDS = ['namespace', 'class', 'struct', 'enum', 'union']

    vim.command('set foldmethod=manual')
    vim.command('normal zE') # eliminate all folds
    win = vim.current.window
    initial_pos = win.cursor

    # decision to create a fold and leave it open/closed will be made based
    # on these criteria applied to the current and previous line
    class Crit:
        def __init__(self, line):
            tokens = line.split() # TODO: better tokenization
            self.has_keyword = len(set(tokens).intersection(KEYWORDS)) > 0
            self.starts_keyword = len(tokens) > 0 and tokens[0] in KEYWORDS
            self.has_open = '{' in line
            self.only_open = line.strip() == '{'
            self.empty = len(line.strip()) == 0

    folds = [] # (fold start pos, fold end pos, True if folded by default)
    prev = None

    for (i, line) in enumerate(vim.current.buffer):
        crit = Crit(line)
        if prev is None:
            prev = crit
            continue

        create_fold = (crit.has_open and crit.has_keyword) or crit.only_open
        unfold_by_default = \
               crit.has_keyword \
            or (prev.starts_keyword and crit.only_open) \
            or (prev.empty and crit.only_open)

        if create_fold:
            fold_start_pos = (i+1, line.find('{')+1)
            win.cursor = fold_start_pos
            vim.command('normal %')
            folds.append((fold_start_pos, win.cursor, unfold_by_default))
            win.cursor = fold_start_pos

        prev = crit

    # create all folds
    for (start_pos, end_pos, _) in folds:
        vim.command('%d,%dfold' % (start_pos[0], end_pos[0]))
        vim.command('normal zR')

    # fold what needs to be folded by default
    folds.sort(reverse=True)
    for (start_pos, _, leave_open) in folds:
        if not leave_open:
            vim.command('%dfoldclose' % start_pos[0])

    # attempt to restore previous position
    win.cursor = initial_pos
endpython

autocmd FileType cpp python3 create_c_folds()
autocmd FileType c python3 create_c_folds()
" }}}

python3 <<endpython
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
endif
" }}}

" Normal mode mappings {{{
" Muscle memory from web browsers
noremap <C-T> :tabnew<Enter>

" splitting similar to tmux
noremap <C-w>% :vsplit<Enter>
noremap <C-w>" :split<Enter>

let mapleader = ","
noremap <silent> <leader><cr> :noh<cr>
noremap <silent> <leader>s :set invspell<cr>

nnoremap <silent> <Leader>z :python3 create_c_folds()<Cr>
nnoremap <silent> <Leader>l :let @+ = expand('%:p') . ':' . line('.')<Cr>
nnoremap <silent> <Leader>d :r! date +\%Y-\%m-\%d:<Cr>
nnoremap <silent> <Leader>b ifrom IPython import embed; embed()<Cr><Esc>

" clang-format (use the one with llvm 3.6.0) not the system default
noremap <silent> <Leader>f :py3file /usr/share/clang/clang-format-5.0/clang-format.py<Cr>
noremap <silent> <Leader>F :%py3file /usr/share/clang/clang-format-5.0/clang-format.py<Cr>
noremap <silent> <Leader>K :YcmCompleter GetDoc<Cr>
noremap <silent> <Leader>p :pclose<Cr>

" short help screen for leader shortcuts (at the top of .vimrc)
noremap <silent> <Leader>h :pedit! $HOME/.vimrc<Cr>

" copy current file and location to clipboard
noremap <silent> <Leader>l :let @+ = expand('%:p') . ":" . line('.')<Cr>
" }}}

" Enable spell checking by default on git commits.
autocmd FileType gitcommit setlocal spell

" Mark 80 and 100 column.
set colorcolumn=80,100
highlight ColorColumn ctermbg=Black

set nojoinspaces

" Pasting the secondary selection can be done with (WARNING: has problems):
"    bash -c "xdotool type --clearmodifiers -- \"`xclip -o -selection secondary`\""
" To copy from secondary to the main clipboard:
"    sh -c "xclip -o -selection secondary | xclip -i -selection clipboard"
"
" autocmd FocusLost * silent exec "!echo -n '" . expand('%:p') . ":" . line('.') . "' | xclip -i -selection secondary"

" vim:set foldmethod=marker:
