#!/usr/bin/env bash

cd /home/vagrant
source /home/vagrant/.bash_rbenv
rbenv install 2.7.5
rbenv install 3.1.0
rbenv global 2.7.5
gem install bundler
