#!/bin/bash

# Configuration
export PROJECT_USER=$1
export INSTALL_DIR=`pwd`
export PROJECT_CONF=$INSTALL_DIR/elementsProject
source $PROJECT_CONF

# Required
apt-get update && apt-get upgrade
apt-get install git build-essential libtool autotools-dev autoconf pkg-config libssl-dev libboost-all-dev libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler imagemagick librsvg2-bin libqrencode-dev autoconf openssl libssl-dev libevent-dev libminiupnpc-dev jq  haskell-platform xz-utils autotools-dev automake g++ gpp pkg-config libdb++-dev libboost-all-dev libncurses-dev make
apt-get update --fix-missing

# Berkeley DB
cd $PROJECT_DIR
git clone https://github.com/ElementsProject/elements.git
chmod 0755 $PROJECT_ELEMENTS_DIR && chown PROJECT_USER $PROJECT_BITCOIN_DIR
cd $PROJECT_ELEMENTS_DIR
./contrib/install_db4.sh $DB4_INSTALL_PATH

# Bitcoin
cd $PROJECT_DIR
git clone https://github.com/roconnor-blockstream/bitcoin.git
chmod 0755 $PROJECT_BITCOIN_DIR && chown PROJECT_USER $PROJECT_BITCOIN_DIR
cd $PROJECT_BITCOIN_DIR
git checkout simplicity
./autogen.sh
./configure BDB_LIBS="-L${BDB_PREFIX}/lib -ldb_cxx-4.8" BDB_CFLAGS="-I${BDB_PREFIX}/include" --disable-dependency-tracking --with-gui=no --disable-test --disable-bench
make
cd $PROJECT_BITCOIN_DIR
alias btc="$PROJECT_BITCOIN_DIR/src/./bitcoin-cli -regtest"
alias btcd="$PROJECT_BITCOIN_DIR/src/./bitcoind -regtest"
btcd -daemon

# Simplicity
cd $PROJECT_DIR
git clone https://github.com/ElementsProject/simplicity.git
chmod 0755 $PROJECT_SIMPLICITY_DIR && chown PROJECT_USER $PROJECT_SIMPLICITY
cabal update
cabal install bech32-1.0.2
cabal install unification-fd cereal lens-family-2.0.0 SHA MemoTrie
cd $PROJECT_SIMPLICITY_DIR
git checkout 2867955c0c93418f45ffe8ea0a7b1277b785fdc4
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
mkdir $PROJECT_HAL_DIR
chmod 0755 $PROJECT_HAL_DIR && chown PROJECT_USER $PROJECT_HAL_DIR
cd $PROJECT_HAL_DIR
wget https://github.com/stevenroose/hal/releases/download/v0.6.1/hal-0.6.1-vendored.tar.gz
tar xzf hal-0.6.1-vendored.tar.gz
cargo install hal
mkdir -m 0755 /nix && chown $PROJECT_USER /nix
curl https://nixos.org/nix/install | sh
. /home/$PROJECT_USER/.nix-profile/etc/profile.d/nix.sh
cd $PROJECT_SIMPLICITY_DIR 
nix-shell -p "(import ./default.nix {}).haskellPackages.ghcWithPackages (pkgs: with pkgs; [Simplicity bech32])"
alias simplicityenv="cd $PROJECT_SIMPLICITY_DIR && nix-shell -p \"(import ./default.nix {}).haskellPackages.ghcWithPackages (pkgs: with pkgs; [Simplicity bech32])\"

# Elements
cd $PROJECT_ELEMENTS_DIR
./autogen.sh
./configure BDB_LIBS="-L${BDB_PREFIX}/lib -ldb_cxx-4.8" BDB_CFLAGS="-I${BDB_PREFIX}/include" --disable-dependency-tracking --with-gui=no --disable-test --disable-bench
make
make install
which elementsd

# Personas
cd $PROJECT_ELMENTS_DIR/contrib/assets_tutorial
mkdir $USER_BITCOIN_DIR
cp ./bitcoin.conf $BITCOIN_DIR/bitcoin.conf
mkdir $USER_ALICE_DIR
cp ./elements1.conf $USER_ALICE_DIR/elements.conf
mkdir $USER_BOB_DIR
cp ./elements2.conf $USER_BOB_DIR/elements.conf

# start deamons
b-dae
alice-dae
bob-dae

# Personas address creation
ALICE_MINER_ADDRESS=$(alice-cli getnewaddress)
echo "ALICE_MINER_ADDRESS=$ALICE_MINER_ADDRESS" >> $PROJECT_CONF
ALICE_RECEIVER_ADDRESS=$(alice-cli getnewaddress)
echo "ALICE_RECEIVER_ADDRESS=$ALICE_RECEIVER_ADDRESS" >> $PROJECT_CONF
BOB_RECEIVER_ADDRESS=$(bob-cli getnewaddress)
echo "BOB_RECEIVER_ADDRESS=$BOB_RECEIVER_ADDRESS" >> $PROJECT_CONF

