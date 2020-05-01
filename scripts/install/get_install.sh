#!/bin/bash

apt-get install git
git clone https://github.com/crypto-hackathons/ElementsInstall.git
cd ElementsInstall/scriot/install
chmod +x install.sh
./install.sh $USER
