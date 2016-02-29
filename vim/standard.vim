" A tweaked vimrc for day to day editing
"
" Original Author : Valentin Roussellet
"                   louen -at- palouf.org
" Uses the "minimal vimrc" as a base
" It only uses standard features of vim to be portable
" across platforms

" Table of sections
" =================

" Minimal vimrc :  starting point of this file
" General VIM interface : base settings for VIM behaviour
" Text Formatting : text input and formats
" Search : behaviour of the search functions
" Status line and informations : bottom lines configuration
" Colors : configuration of fonts and text colors
" Helper functions : functions used by mappings
" Key mappings : re-mapping of the key strokes
" Bug fixes and workarounds : things that should not be there but are

" 1. Minimal vimrc
" ================

" This must be first, because it changes other options as a side effect
set nocompatible

" Make backspace behave in a sane manner
set backspace=indent,eol,start

" Switch syntax highlighting on
syntax on

" Enable file type detection and do language-dependent indenting
filetype plugin indent on

" Show line numbers
set number

" Allow hidden buffers, don't limit to 1 file per window/split
set hidden

" Use visual bell (i.e. flash) instead of beeps
set visualbell


" 2. General VIM interface
" ========================

" Keep lines visible above and below the cursor
set scrolloff=2

" Add an extra column of padding on the left side
set foldcolumn=1

" Allow left and right arrows to go up or down one line when at one end
set whichwrap=<,>,[,]

" Try to keep the same column while moving up or down
set nostartofline

" If a file has been changed while being edited, automatically reload it
set autoread

" Allow terminal emulators with mouse support to use the mouse
if has('mouse')
    set mouse=a
endif

" == Searching and regexps ==

" Interpret some characters (like ^ and $ ) by default in regexp
set magic

" Show matching delimiters when writing one ( [], {}, () )
set showmatch

" Hilight matching for 20ms (instead of 50)
set matchtime=2

" == Bottom line commands ==

" Show suggestions when autocompleting with <tab>
set wildmenu

" Using autocomplete with <tab>, if there is an ambiguity,
" we list all possible options and complete with the first
set wildmode=list:full

" Configure how many lines of history to remember
set history=500

" Configure the .viminfo file which keeps data about which
" edited files, history, registers, etc
" '50   = remember at most 50 files
" <1000 = remember at most 1000 lines for each register
" s100  = do not save registers more than 100 kB
" no /  = save te search history
" no h  = keep the last `hlsearch`
" no %  = do not load the last files edited when invoking `vim`
set viminfo='20,<1000,s100

" Configure the messages printed at bottom line
" a = all terse messages (e.g. [+] instead of [Modified]
" t = truncate file names
" T = truncate long messages
" o and O : only display the last message in write/read operations
" I : don't display the intro message when starting vim without args
set shortmess=atToOI


" 3. Text formatting
" ==================

" Do not wrap long lines
set nowrap
set textwidth=0

" == Tabs and indentation ==
" Reference : http://tedlogan.com/techblog3.html
" In modern code tabs are printed as 4 spaces

" When adding a new line, it will keep the indentation level of the
" current line
set autoindent

" Some prefer real tabs and some prefer spaces
" Here we use spaces only
set expandtab

"    use `set noexpandtab` if you want real tabs
"    The rest of the settings should work consistently

" Number of columns an indentation level will be displayed as
set tabstop=4

" Number of spaces inserted when indenting ( >> )
set shiftwidth=4

" Number of spaces inserted when pressing tab
" This is only useful if different from tabstop
set softtabstop=4

" Inserting tabs at beginning of lines always insserts 4 spaces
" inserting tabs in text inserts spaces up to the next tabstop
set smarttab

" 4. Search
" =========

" Searches ignore case by default...
set ignorecase

" ... except if the pattern contains upper case caracters
set smartcase

" Note : if you want to force the search to be case sensitive, use /foo\C

" Highlight matches when searching. use :noh to turn it off after the search
set hlsearch

" Real-time display of the matched patterns while typing
set incsearch


" 5. Status line and informations
" ===============================

" Show the command you are typing in the status bar
set showcmd

" Always show a status bar even with one file
set laststatus=2

" == Status line configuration ==

set statusline=""
" Left side : prints file and flags
set statusline+=[%{strlen(&fenc)?&fenc:'none'}] " File encoding
set statusline+=%m        " [+] if file is modified, [-] if not modifiable
set statusline+=%r        " [RO] if file is readonly
set statusline+=%y        " File type in [ ]
set statusline+=%#todo#   " Switch highlight and use one of the highlight groups
set statusline+=%40.40(\ \ %<%F\ \ %) " File name, truncated left
set statusline+=%*        " Switch hilight to normal

set statusline+=%=        " Take a walk on the right side

" Right side : emulate `set ruler`
set statusline+=%#todo#   " Switch highlight
set statusline+=%-15.(\ %l,%c%V%)  " Print line number, column numbers
set statusline+=%*        " Switch hilight to normal
set statusline+=%P        " Print file percentage


" 6. Colors
" =========

" When you go dark you never go back
set background=dark

" Use a standard colorscheme that works everywhere
colorscheme elflord


" 7. Helper functions
" ===================

" This function toggles between absolute and relative
" line numbering (very useful when moving across lines)
function NumberToggle()
    if(&relativenumber == 1)
        set norelativenumber
    else
        set relativenumber
    endif
endfunc


" This function removes trailing whitespace
" It is pretty useful with autocmd BufWrite to avoid
" garbage whitespace (e.g. in python)
function DeleteTrailingWS()
    exe "normal mz"
    %s/\s\+$//ge
    exe "normal `z"
endfunc

" 8. Key mappings
" ===============

" Use ctrl-n in normal mode to toggle numbers
nnoremap <C-n> :call NumberToggle() <CR>

" Use ctrl+space for auto completion like in most editors
" Unfortunately some terminals send Ctrl+@ instead of Ctrl+Space
inoremap <C-Space> <C-N>
imap <C-@> <C-Space>


" *. Bugfixes and workarounds
" ============================

" This prevents the "E303" error message on Windows machines
" http://cfc.kizzx2.com/index.php/gvim-e303-unable-to-open-swap-file-for-no-name-recovery-impossible/
set directory=.,$TEMP
