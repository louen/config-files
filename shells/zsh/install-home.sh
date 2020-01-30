#! /bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# install vimrc

for file in zlogin zshenv zshrc zlogout
do
    rm -f $HOME/.$file
    ln -s $DIR/$file $HOME/.$file
done

rm -f $HOME/.aliases
ln -s $DIR/../aliases $HOME/.aliases
