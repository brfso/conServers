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

sudo cp $PWD/conservers.sh /usr/bin/
sudo cp $PWD/getServers.rb /usr/bin/


