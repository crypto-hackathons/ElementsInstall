#!/bin/bash

# Configuration
export PROJECT_USER=$1
export INSTALL_DIR=`pwd`
export INSTALL_LOG_DIR="$INSTALL_DIR/../../log/install"
export INSTALL_TEST_DIR="$INSTALL_DIR/../../test"
export PROJECT_CONF="$INSTALL_DIR/../../conf/elementsProject.conf"
alias userDo="su $PROJECT_USER -c"

echo "**************"
echo "Params"
echo "**************"
echo "PROJECT_USER = $PROJECT_USER"
echo "INSTALL_DIR = $INSTALL_DIR"
echo "INSTALL_LOG_DIR = $INSTALL_LOG_DIR"
echo "PROJECT_CONF = $PROJECT_CONF"
echo "userDo = su $PROJECT_USER -c"

source $PROJECT_CONF $PROJECT_USER
mkdir $PROJECT_DIR
chmod 0755 $PROJECT_DIR && chown $PROJECT_USER $PROJECT_DIR

echo "**************"
echo "Apt install"
echo "**************"

echo "apt-get update >> $INSTALL_LOG_DIR/apt_update.log"
apt-get update  >> $INSTALL_LOG_DIR/apt_update.log
echo "apt-get upgrade >> $INSTALL_LOG_DIR/apt_upgrade.log"
apt-get upgrade >> $INSTALL_LOG_DIR/apt_upgrade.log

echo "apt-get install git build-essential libtool autotools-dev autoconf pkg-config libssl-dev libboost-all-dev libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler imagemagick librsvg2-bin libqrencode-dev autoconf openssl libssl-dev libevent-dev libminiupnpc-dev jq haskell-platform xz-utils autotools-dev automake g++ gpp pkg-config libdb++-dev libboost-all-dev libncurses-dev make >> $INSTALL_LOG_DIR/apt.log"
apt-get install git build-essential libtool autotools-dev autoconf pkg-config libssl-dev libboost-all-dev libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler imagemagick librsvg2-bin libqrencode-dev autoconf openssl libssl-dev libevent-dev libminiupnpc-dev jq haskell-platform xz-utils autotools-dev automake g++ gpp pkg-config libdb++-dev libboost-all-dev libncurses-dev make >> $INSTALL_LOG_DIR/apt.log

echo "apt-get update --fix-missing >> $INSTALL_LOG_DIR/apt_missing.lo"
apt-get update --fix-missing >> $INSTALL_LOG_DIR/apt_missing.log

echo "**************"
echo "Berkeley DB"
echo "**************"
cd $PROJECT_DIR
git clone https://github.com/ElementsProject/elements.git
chmod 0755 $PROJECT_ELEMENTS_DIR && chown $PROJECT_USER $PROJECT_BITCOIN_DIR
cd $PROJECT_ELEMENTS_DIR

echo "./contrib/install_db4.sh $DB4_INSTALL_PATH >> $INSTALL_LOG_DIR/bd4.log"
./contrib/install_db4.sh $DB4_INSTALL_PATH >> $INSTALL_LOG_DIR/bd4.log

echo "**************"
echo "Bitcoin"
echo "**************"
cd $PROJECT_DIR
git clone https://github.com/roconnor-blockstream/bitcoin.git
chmod 0755 $PROJECT_BITCOIN_DIR && chown $PROJECT_USER $PROJECT_BITCOIN_DIR
cd $PROJECT_BITCOIN_DIR
git checkout simplicity
userDo ./autogen.sh

echo "userDo ./configure BDB_LIBS=\"-L${BDB_PREFIX}/lib -ldb_cxx-4.8\" BDB_CFLAGS=\"-I${BDB_PREFIX}/include\" --disable-dependency-tracking --with-gui=no --disable-test --disable-bench >> $INSTALL_LOG_DIR/bitcoin_configure.log"
userDo ./configure BDB_LIBS="-L${BDB_PREFIX}/lib -ldb_cxx-4.8" BDB_CFLAGS="-I${BDB_PREFIX}/include" --disable-dependency-tracking --with-gui=no --disable-test --disable-bench >> $INSTALL_LOG_DIR/bitcoin_configure.log
 
echo "make >> $INSTALL_LOG_DIR/bitcoin_make.log" 
make >> $INSTALL_LOG_DIR/bitcoin_make.log

cd $PROJECT_BITCOIN_DIR

alias btc="$PROJECT_BITCOIN_DIR/src/./bitcoin-cli -regtest"
echo "btc = $PROJECT_BITCOIN_DIR/src/./bitcoin-cli -regtest"

alias btcd="$PROJECT_BITCOIN_DIR/src/./bitcoind -regtest"
echo "btcd = $PROJECT_BITCOIN_DIR/src/./bitcoind -regtest"

btcd -daemon

echo "**************"
echo "Simplicity"
echo "**************"
cd $PROJECT_DIR
git clone https://github.com/ElementsProject/simplicity.git
chmod 0755 $PROJECT_SIMPLICITY_DIR && chown $PROJECT_USER $PROJECT_SIMPLICITY
userDo cabal update
userDo cabal install bech32-1.0.2
userDo cabal install unification-fd cereal lens-family-2.0.0 SHA MemoTrie
cd $PROJECT_SIMPLICITY_DIR
git checkout 2867955c0c93418f45ffe8ea0a7b1277b785fdc4
userDo curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
userDo source $HOME/.cargo/env
mkdir $PROJECT_HAL_DIR
chmod 0755 $PROJECT_HAL_DIR && chown $PROJECT_USER $PROJECT_HAL_DIR
cd $PROJECT_HAL_DIR
wget https://github.com/stevenroose/hal/releases/download/v0.6.1/hal-0.6.1-vendored.tar.gz
userDo tar xzf hal-0.6.1-vendored.tar.gz
userDo cargo install hal
mkdir -m 0755 /nix && chown $PROJECT_USER /nix
userDo curl https://nixos.org/nix/install | sh
userDo . /home/$PROJECT_USER/.nix-profile/etc/profile.d/nix.sh
cd $PROJECT_SIMPLICITY_DIR 
userDo nix-shell -p "(import ./default.nix {}).haskellPackages.ghcWithPackages (pkgs: with pkgs; [Simplicity bech32])"

alias simplicityenv="cd $PROJECT_SIMPLICITY_DIR && nix-shell -p \"(import ./default.nix {}).haskellPackages.ghcWithPackages (pkgs: with pkgs; [Simplicity bech32])\""
echo "simplicityenv = cd $PROJECT_SIMPLICITY_DIR && nix-shell -p \"(import ./default.nix {}).haskellPackages.ghcWithPackages (pkgs: with pkgs; [Simplicity bech32])\""

echo "**************"
echo "Elements"
echo "**************"
cd $PROJECT_ELEMENTS_DIR
userDo ./autogen.sh

echo "userDo ./configure BDB_LIBS=\"-L${BDB_PREFIX}/lib -ldb_cxx-4.8\" BDB_CFLAGS=\"-I${BDB_PREFIX}/include\" --disable-dependency-tracking --with-gui=no --disable-test --disable-bench >> $INSTALL_LOG_DIR/elements_congigure.log"
userDo ./configure BDB_LIBS="-L${BDB_PREFIX}/lib -ldb_cxx-4.8" BDB_CFLAGS="-I${BDB_PREFIX}/include" --disable-dependency-tracking --with-gui=no --disable-test --disable-bench >> $INSTALL_LOG_DIR/elements_congigure.log

echo "make >> $INSTALL_LOG_DIR/elements_make.log"
make >> $INSTALL_LOG_DIR/element_make.log

echo "make install >> $INSTALL_LOG_DIR/elements_make_install.log"
make install >> $INSTALL_LOG_DIR/elements_make_install.log
which elementsd

echo "**************"
echo "Personas"
echo "**************"
cd $PROJECT_ELMENTS_DIR/contrib/assets_tutorial

mkdir $USER_BITCOIN_DIR
chmod 0755 $USER_BITCOIN_DIR && chown $PROJECT_USER $USER_BITCOIN_DIR
cp ./bitcoin.conf $BITCOIN_DIR/bitcoin.conf

mkdir $USER_ALICE_DIR
chmod 0755 $USER_ALICE_DIR && chown $PROJECT_USER $USER_ALICE_DIR
cp ./elements1.conf $USER_ALICE_DIR/elements.conf

mkdir $USER_BOB_DIR
chmod 0755 $USER_BOB_DIR && chown $PROJECT_USER $USER_BOB_DIR
cp ./elements2.conf $USER_BOB_DIR/elements.conf

echo "**************"
echo "Start deamons"
echo "**************"
b-dae
alice-dae
bob-dae

echo "**************"
echo "Personas address"
echo "**************"
userDo ALICE_MINER_ADDRESS=$(alice-cli getnewaddress)
echo "ALICE_MINER_ADDRESS=$ALICE_MINER_ADDRESS" >> $PROJECT_CONF
echo "echo \"ALICE_MINER_ADDRESS = \$ALICE_MINER_ADDRESS\"" >> $PROJECT_CONF

userDo ALICE_RECEIVER_ADDRESS=$(alice-cli getnewaddress)
echo "ALICE_RECEIVER_ADDRESS=$ALICE_RECEIVER_ADDRESS" >> $PROJECT_CONF
echo "echo \"ALICE_RECEIVER_ADDRESS = \$ALICE_RECEIVER_ADDRESS\"" >> $PROJECT_CONF

userDo BOB_RECEIVER_ADDRESS=$(bob-cli getnewaddress)
echo "BOB_RECEIVER_ADDRESS=$BOB_RECEIVER_ADDRESS" >> $PROJECT_CONF
echo "echo \"BOB_RECEIVER_ADDRESS = \$BOB_RECEIVER_ADDRESS\"" >> $PROJECT_CONF

echo "ALICE_MINER_ADDRESS = $ALICE_MINER_ADDRESS"
echo "ALICE_RECEIVER_ADDRESS = $ALICE_RECEIVER_ADDRESS"
echo "BOB_RECEIVER_ADDRESS = $BOB_RECEIVER_ADDRESS"

echo "**************"
echo "chmod +x"
echo "**************"
chmod +x $INSTALL_DIR/elementsProjectStart.sh
chmod +x $INSTALL_DIR/elementsProjectStop.sh
chmod +x $INSTALL_TEST_DIR/test_transaction_simple.sh

cd  $INSTALL_LOG_DIR
ls -al