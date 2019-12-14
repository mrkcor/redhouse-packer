#!/usr/bin/env bash

cd /home/vagrant
source /home/vagrant/.bash_rbenv
rbenv install 2.6.5
rbenv global 2.6.5
gem install bundler
