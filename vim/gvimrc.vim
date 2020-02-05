" GVIMrc file for GUI-related configuration
" Original Author : Valentin Roussellet
"                   louen -at- palouf.org

" Main options for GUI
set guioptions-=T " No toolbox 
set guioptions-=r " No right scrollbar
set guioptions-=R " No right scrollbar
set guioptions-=l " No left scrollbar
set guioptions-=L " No left scrollbar


if has("gui_gtk2")
    set guifont=Source\ Code\ Pro\ 10,DejaVu\ Sans\ Mono\ 10
elseif has("gui_win32")
    set guifont=Source\ Code\ Pro:h9:cANSI,Consolas:h10:cANSI
elseif has("gui_macvim")
    set macligatures    " Enable ligatures for Fira Code
    set guifont=Fira\ Code:h14,Monaco:h14   
    aunmenu TouchBar    " Disable the fullscreen button on tthe macbook touchbar
endif

" Use a more friendly (yet ubiquitous) scheme on gVim
colorscheme desert

