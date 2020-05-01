Tested for Debian 10.

Your machine needs at least 1.5 GB of memory and 12 GB of storage.

# Elements Project Environnement

## Configure:

Your configuration in the conf/elementsProject.conf file.

## Install:

In superuser: wget https://github.com/crypto-hackathons/ElementsInstall/blob/master/scripts/install/get_install.sh | sh

Or

Copy files and Type in superuser: cd scripts && chmod +x .install.sh && ./install.sh $USER

## Start:

Type: scripts/./elementsProjectStart.sh $USER

## Stop:

Type: scripts/./elementsProjectStop.sh $USER

## Test:

Type: test/./test_transaction_simple.sh $USER
