#!/bin/bash
# 
# Script: Install.sh
# Description: conServer Installer

SO=$(uname -v | awk '{print $1}')

if [ ${SO} == "Darwin" ];
  then
    echo "Helo, your Operation System is Mac, now we are installing Zenity from brew"
    brew install zenity
else
    echo "Helo, your Operation System is Linux, now we are installing requirements from apt-get"
    sudo apt-get -y install libgmp-dev 
    sudo apt-get -y ruby ruby-dev
    sudo apt-get -y zenity
    sudo apt-get -y zlib1g-dev
    sudo apt-get -y bundler
fi     
echo "Initiating bundle install"
bundle install

echo "Copy files and set permissions" 
sudo cp $PWD/conservers.sh /usr/local/bin/
sudo chmod +rx /usr/local/bin/conservers.sh
sudo cp $PWD/conservers.config /etc/
sudo chmod +r /etc/conservers.config
sudo cp $PWD/getServers.rb /usr/local/bin/
sudo chmod +rx /usr/local/bin/getServers.rb

echo "Congrats, sucessfull installation!"
echo "1. Configure your URL in /etc/conservers.config"
echo "2. Enjoy. use: \$ conserver.sh" 
