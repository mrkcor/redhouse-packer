#!/usr/bin/env bash

cd /home/vagrant
source /home/vagrant/.bash_rbenv
rbenv install 2.6.5
rbenv install 2.6.6
rbenv install 2.7.1
rbenv global 2.6.5
gem install bundler
