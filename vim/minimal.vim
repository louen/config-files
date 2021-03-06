" A minimal vimrc for new vim users to start with.
"
" References
" http://www.benorenstein.com/blog/your-first-vimrc-should-be-nearly-empty/
" https://gist.github.com/benmccormick/4e4bc44d8135cfc43fc3
"
"
" Original Author:       Bram Moolenaar <Bram@vim.org>
" Made more minimal by:  Ben Orenstein
" Modified by :          Ben McCormick
" Modified by :          Valentin Roussellet
" Last change:           2016 Jan 20
"
" To use it, copy it to
"  for Unix based systems (including OSX and Linux):  ~/.vimrc
"  for Windows :  $VIM\_vimrc
"
" If you don't understand a setting in here, just type ':h setting'
" Use Vim settings, rather than Vi settings (much better!)
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
