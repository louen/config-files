#! /bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# install vimrc

rm -f $HOME/.vimrc
ln -s $DIR/standard.vim $HOME/.vimrc  

rm -f $HOME/.gvimrc
ln -s $DIR/gvimrc.vim $HOME/.gvimrc  
