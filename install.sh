#!/bin/bash
# 
# Script: Install.sh
# Description: conServer Installer

RUBY_PKG=`which ruby`

${RUBY_PKG} -v

if [ $? != "0" ]; then
	echo "Ruby is not installed, install Ruby first"
	exit 1
fi

bundle install

sudo cp $PWD/conservers.sh /usr/local/bin/
sudo chmod +rx /usr/local/bin/conservers.sh
sudo cp $PWD/conservers.config /etc/
sudo chmod +r /etc/conservers.config
sudo cp $PWD/getServers.rb /usr/local/bin/
sudo chmod +rx /usr/local/bin/getServers.rb
