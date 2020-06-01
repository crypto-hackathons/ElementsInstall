# Elements + Simplicity Project Environnement

Tested for Debian 10.

Your machine needs at least 1.5 GB of memory and 12 GB of storage.

A project for build an Elements + Simplicity project environnement (dev, test or prod)

## Configure:

Your configuration in the conf/elementsProject.conf file.

## Install:

/!\ The install take around 2h

$ git clone https://github.com/crypto-hackathons/ElementsInstall.git
$ su
\# cd ElementsInstall/scripts/install
\# chmod +x install.sh && ./install.sh -u $USER -a yes -k yes -b yes -s yes -n yes -e yes -p yes -j yes -w yes -v regtest

u) User: user name (user datas in the home directory)

a) APT: "yes" for install

k) BERKELEY_DB: "yes" for install

b) BITCOIN: "yes" for install

s) SIMPLICITY: "yes" for install

n) NIX: "yes" for install

e) ELEMENTS: "yes" for install

p) PERSONAS: "yes" for install Bob and Alice Elements wallets, Alice is a also a miner

v) NODES: "yes" for install

v) WALLET: "yes" for install Bcoin lib (https://github.com/bcoin-org/bcoin)

v) ENVIRONNEMENT: [main], [test] or [regtest] for configuration 

## Start:

Type: scripts/./elementsProjectStart.sh -u $USER -v $ENVIRONNEMENT

## Stop:

Type: scripts/./elementsProjectStop.sh -u $USER -v $ENVIRONNEMENT

## Test:

Type: test/./test_transaction_simple.sh -u $USER -v $ENVIRONNEMENT
