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
" Search and completion : behaviour of the search functions
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

" Disable error beeps
set noerrorbells

" Use visual bell (i.e. flash) instead of beeps
set visualbell


" 2. General VIM interface
" ========================

" Do not parse modelines. This feature is moderately useful to do
" per-file configuration but is a huge security vulnerability
set nomodeline

" Keep lines visible above and below the cursor
set scrolloff=2

" Keep colums visible around the cursor
set sidescrolloff=5

" Add an extra column of padding  for folds on the left side
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

" Display the title in the terminal window
set title

" Open vertical splits on the right side
set splitright


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

" Files to ignore in the menu when looking for a file.
set wildignore+=*.o,*.out,*.obj " C/C++ outputs
set wildignore+=.git,.svn       " Version control system dirs
set wildignore+=*.zip,*.tar,*tar.gz,*.tar.bz2,*.rar " Compressed dirs
set wildignore+=*.swp,*~,._* "Swap and backup files

" Using autocomplete with <tab>, if there is an ambiguity,
" we complete with the first (the options being listed in
" wildmenu set above)
set wildmode=longest,full

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
" !     = save uppercase variables in viminfo file
set viminfo='20,<1000,s100,!

" Configure the messages printed at bottom line
" a = all terse messages (e.g. [+] instead of [Modified]
" t = truncate file names
" T = truncate long messages
" o and O = only display the last message in write/read operations
" I = don't display the intro message when starting vim without args
set shortmess=atToOI


" 3. Text formatting
" ==================

" Use utf8 as default encoding
set encoding=utf8

" Do not wrap long lines
set nowrap
set textwidth=0

" Display the last line as much as possible instead of '@'
set display+=lastline

" Do not consider numbers starting with 0 as octal (e.g for increment)
set nrformats-=octal

" Joining comment lines remove the leading comment signs
set formatoptions+=j

" Set default whitespace chars for 'set list'
set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+

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


" 4. Search and completion
" ========================

" Searches ignore case by default...
set ignorecase

" ... except if the pattern contains upper case caracters
set smartcase

" Note : if you want to force the search to be case sensitive, use /foo\C

" Highlight matches when searching. use :noh to turn it off after the search
set hlsearch

" Real-time display of the matched patterns while typing
set incsearch

" Don't scan include files for completion (rely on .tags)
" or external completer instead
set complete-=i


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
set statusline+=%#visual# " Switch highlight and use one of the highlight groups
set statusline+=%40.40(\ \ %<%F\ \ %) " File name, truncated left
set statusline+=%*        " Switch hilight to normal

set statusline+=%=        " Take a walk on the right side

" Right side : emulate `set ruler`
set statusline+=%#visual# " Switch highlight
set statusline+=%-15.(\ %l,%c%V%)  " Print line number, column numbers
set statusline+=%*        " Switch hilight to normal
set statusline+=%P        " Print file percentage


" 6. Colors
" =========

" When you go dark you never go back
set background=dark

" Use a standard colorscheme that works everywhere
colorscheme elflord

" Display the current line
set cursorline

" I don't like the default underline for cursorline
hi CursorLine term=bold cterm=bold

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

" Timeout for key sequences ( maps ) set to 1s
set timeout
set timeoutlen=1000

" Timeout for key codes (e.g with <Esc>) set to 100ms
set ttimeout
set ttimeoutlen=100


" Start by defining the leader to ',' instead of '\'
" which is not very convenient
let mapleader=","


" Use leader+/ to un-highlight searched items
nnoremap <silent> <leader>/  :nohlsearch<CR>

" Use leader+space to clean whitespace
nnoremap <leader><space> :call DeleteTrailingWS() <CR>

" Use Ctrl-N in normal mode to toggle numbers
nnoremap <C-n> :call NumberToggle() <CR>

" Use ctrl+space for auto completion like in most editors
" Unfortunately some terminals send Ctrl+@ instead of Ctrl+Space
inoremap <C-Space> <C-N>
imap <C-@> <C-Space>

" == Tabs shortcuts ==

" Cycle tabs with leader Ctrl+tab
nnoremap <leader><tab>   :tabnext<CR>
nnoremap <leader><S-tab> :tabprevious<CR>

" Create a new tab with leader Ctrl+T
nnoremap <leader><C-t> :tabnew<CR>

" Close a tab with leader Ctrl+W
nnoremap <leader><C-w> :tabclose<CR>

" == Splits shortcuts ==

" Map H and V to split and vsplit
nnoremap<leader>h :<C-u>split<CR>
nnoremap<leader>v :<C-u>vsplit<CR>

" == Buffer shortcuts ==

" Use Q and W to cycle buffers
nnoremap <leader>q :bprevious<CR>
nnoremap <leader>w :bnext<CR>

" == Window shortcuts

" Move windows with ctrl + hjkl
"nnoremap <C-h><C-w>h
"nnoremap <C-j><C-w>j
"nnoremap <C-k><C-w>k
"nnoremap <C-l><C-w>l

" == Other maps ==

" Keep visual mode after indenting with > or <
vmap < <gv
vmap > >gv

" I don't use Ex mode when running vim interactively.
nnoremap Q <nop>

" == Abbrevs ==

" Use :H for opening help in a vsplit
cnoreabbrev H vert h

" Remap common caps typos to their correct versions
cnoreabbrev W! w!
cnoreabbrev Q! q!
cnoreabbrev Qall! qall!
cnoreabbrev Wq wq
cnoreabbrev Wa wa
cnoreabbrev wQ wq
cnoreabbrev WQ wq
cnoreabbrev W w
cnoreabbrev Q q
cnoreabbrev Qall qall

" *. Bugfixes and workarounds
" ============================

" This prevents the "E303" error message on Windows machines
" http://cfc.kizzx2.com/index.php/gvim-e303-unable-to-open-swap-file-for-no-name-recovery-impossible/
set directory=.,$TEMP
