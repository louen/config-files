" GVIMrc file for GUI-related configuration
" Original Author : Valentin Roussellet
"                   louen -at- palouf.org

" I use Source Code Pro as my default font for gVim
if has("gui_gtk2")
    set guifont=Source\ Code\ Pro\ 10
elseif has("gui_win32")
    set guifont=Source\ Code\ Pro:h9:cANSI
endif

