#!/usr/bin/env bash

git clone https://github.com/rbenv/rbenv.git ~/.rbenv
cd ~/.rbenv && src/configure && make -C src

echo 'export PATH="$HOME/.rbenv/bin:$PATH"' > ~/.bash_rbenv
echo 'eval "$(rbenv init -)"' >> ~/.bash_rbenv
echo 'source ~/.bash_rbenv' >> ~/.bashrc
