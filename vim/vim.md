# The quest for the perfect vim

`vim` rules. Vim is useful everywhere but it needs configuration.
Sometimes different configurations for different use cases.
This is mainly a doc for me as I was building the perfect vimrc.

Note : `vim -u config_file` to force the use of a given config

Each option is throughrly commented. You can always use 
`:h <option-name>` to access the matching section of the 
vim documentation.

## The minimal vimrc

Many vim tutorials recommend using the smallest possible vimrc
to start with. This way it is possible to get familiar with the 
editor without resorting to tricks and tweaks. It also allows
a better understanding of which setting changes what.

I used Ben Orenstein's minimal vimrc for starters, with 
a few tweaks of my own, which is in `vimrc.minimal`

## A good console editor

Now my goal will be to make vim usable as my main editor in 
a terminal, to edit files as a sysadmin or to make a quick
fix in a program. So the configuration will need to be 
simple and fast to load, with no frills, but still make
it convenient to use. Also it will need to work with
all kind of terminals. `vimrc.standard` 

Note that compatibility is only guaranteed with vim 7.4+.

So far I tested my file in the following environments and terminals
* Linux : Konsole, gnome-terminal, xterm, urxvt
* Windows : cygwin terminal, puTTY

### Maps summary


#### Credits

I took inspiration from many other goods vimrc
and vim documentation on github such as
* `vim-sensible` by Tim Pope ( https://github.com/tpope/vim-sensible ) 
*  Extra `vim-sensible` config by Adam Stankiewicz ( https://github.com/sheerun/vimrc )
* `vim-galore` by Marco Hinz ( https://github.com/mhinz/vim-galore )

## A good graphical editor

I added a `gvimrc` file to configure when running graphical vim.
It contains only options for gvim, such as setting guioptions
and fonts for gvim.


