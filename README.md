# Elements + Simplicity Project Environnement

Tested for Debian 10.

Your machine needs at least 1.5 GB of memory and 12 GB of storage.

A project for build an Elements + Simplicity project environnement (dev, test or prod)

## Configure:

Your configuration in the conf/elementsProject.conf file.

## Install:

/!\ The install take around 2h

Ccopy files or
git clone https://github.com/crypto-hackathons/ElementsInstall.git

And type in superuser: cd ElementsInstall/scripts && chmod +x install.sh && ./install.sh -u $USER -a yes -k yes -b yes -s yes -n yes -e yes -p yes

u) User namme

a) APT install

k) BERKELEY_DB install

b) BITCOIN install

s) SIMPLICITY install

n) NIX install

e) ELEMENTS install

p) PERSONAS install


## Start:

Type: scripts/./elementsProjectStart.sh $USER

## Stop:

Type: scripts/./elementsProjectStop.sh $USER

## Test:

Type: test/./test_transaction_simple.sh $USER
