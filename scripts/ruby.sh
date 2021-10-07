#!/usr/bin/env bash

cd /home/vagrant
source /home/vagrant/.bash_rbenv
rbenv install 2.7.4
rbenv install 3.0.2
rbenv global 2.7.4
gem install bundler
