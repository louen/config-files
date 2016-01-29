# The quest for the perfect vim

`vim` rules. Vim is useful everywhere but it needs configuration.
Sometimes different configurations for different use cases.
This is mainly a doc for me as I was building the perfect vimrc for me.

Note : `vim -u config_file` to force the use of a given config

I will try to detail why each option is there, mostly as a way
to remember it myself but who knows, it can be useful for 
somebody else.

## The minimal vimrc

Many vim tutorials recommend using the smallest possible vimrc
to start with. This way it is possible to get familiar with the 
editor without resorting to tricks and tweaks. It also allows
a better understanding of which setting changes what.

I used Ben Orenstein's minimal vimrc for starters, with 
a few tweaks of my own, which is in `vimrc.minimal`

## A good console editor

Now my goal will be to make vim useable as my main editor in 
a terminal, to edit files as a sysadmin or to make a quick
fix in a program. So the configuration will need to be 
simple and fast to load, with no frills, but still make
it convenient to use. Also it will need to work with
all kind of terminals. `vimrc.standard` 

### General options

The first section changes the general behavior of vim.

The "fold column" adds a nice padding to the left and will 
also be useful for foldings 



### Text formatting

This section is fairly straightforward, most of it is concerned
by tabs and indentation.

In my file I chose to write spaces instead of real tabs, but
this can easily be overriden, even on a file type basis (this
is done automatically for Makefiles for example).

The rest of the config here is about how many spaces a tab 
is worth.
Default is 8, but most modern editors use 4 (though some people
prefer 2).
The only caveat is to keep the `tabstop`, `shiftwidth` 
and `softtabstop` consistent.

### Status line

### Color schemes

## A good graphical editor

## Compatibility across OS

## A replacement for your IDE


## References

https://github.com/mhinz/vim-galore
