#!/bin/bash

source ../../conf/elementsProject.conf $1
mkdir $PROJECT_DIR
chmod 0755 $PROJECT_DIR && chown $PROJECT_USER $PROJECT_DIR

echo "**************"
echo "Apt install"
echo "**************"
echo "apt-get update >> $INSTALL_LOG_DIR/apt_update.log"
apt-get update >> $INSTALL_LOG_DIR/apt_update.log
echo "apt-get upgrade >> $INSTALL_LOG_DIR/apt_upgrade.log"
apt-get upgrade >> $INSTALL_LOG_DIR/apt_upgrade.log

echo "apt-get install git apt-utils build-essential libtool autotools-dev autoconf pkg-config libssl-dev libboost-all-dev libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler imagemagick librsvg2-bin libqrencode-dev autoconf openssl libssl-dev libevent-dev libminiupnpc-dev jq haskell-platform xz-utils autotools-dev automake g++ gpp pkg-config libdb++-dev libboost-all-dev libncurses-dev make >> $INSTALL_LOG_DIR/apt.log"
apt-get install git build-essential libtool autotools-dev autoconf pkg-config libssl-dev libboost-all-dev libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler imagemagick librsvg2-bin libqrencode-dev autoconf openssl libssl-dev libevent-dev libminiupnpc-dev jq haskell-platform xz-utils autotools-dev automake g++ gpp pkg-config libdb++-dev libboost-all-dev libncurses-dev make >> $INSTALL_LOG_DIR/apt.log

echo "apt-get update --fix-missing >> $INSTALL_LOG_DIR/apt_missing.lo"
apt-get update --fix-missing >> $INSTALL_LOG_DIR/apt_missing.log

echo "**************"
echo "Berkeley DB"
echo "**************"
echo "cd $PROJECT_DIR"
cd $PROJECT_DIR
echo "userDo \"git clone https://github.com/ElementsProject/elements.git\""
userDo "git clone https://github.com/ElementsProject/elements.git"
echo "cd $PROJECT_ELEMENTS_DIR"
cd $PROJECT_ELEMENTS_DIR

echo "./contrib/install_db4.sh $DB4_INSTALL_PATH >> $INSTALL_LOG_DIR/bd4.log"
./contrib/install_db4.sh $DB4_INSTALL_PATH >> $INSTALL_LOG_DIR/bd4.log

echo "**************"
echo "Bitcoin"
echo "**************"
echo "cd $PROJECT_DIR"
cd $PROJECT_DIR
echo "userDo \"git clone https://github.com/roconnor-blockstream/bitcoin.git\""
userDo "git clone https://github.com/roconnor-blockstream/bitcoin.git"
echo "cd $PROJECT_BITCOIN_DIR"
cd $PROJECT_BITCOIN_DIR
echo "userDo \"git checkout simplicity\""
userDo "git checkout simplicity"
# echo "userDo ./autogen.sh >> $INSTALL_LOG_DIR/bitcoin_autogen.log" 
# userDo ./autogen.sh >> $INSTALL_LOG_DIR/bitcoin_autogen.log
echo "./autogen.sh >> $INSTALL_LOG_DIR/bitcoin_autogen.log" 
./autogen.sh >>  $INSTALL_LOG_DIR/bitcoin_autogen.log
echo "userDo \"./configure BDB_LIBS=\"-L${BDB_PREFIX}/lib -ldb_cxx-4.8\" BDB_CFLAGS=\"-I${BDB_PREFIX}/include\" --disable-dependency-tracking --with-gui=no --disable-test --disable-bench >> $INSTALL_LOG_DIR/bitcoin_configure.log\""
userDo "./configure BDB_LIBS="-L${BDB_PREFIX}/lib -ldb_cxx-4.8" BDB_CFLAGS="-I${BDB_PREFIX}/include" --disable-dependency-tracking --with-gui=no --disable-test --disable-bench >> $INSTALL_LOG_DIR/bitcoin_configure.log"
 
echo "make >> $INSTALL_LOG_DIR/bitcoin_make.log" 
make >> $INSTALL_LOG_DIR/bitcoin_make.log

echo "cd $PROJECT_BITCOIN_DIR"
cd $PROJECT_BITCOIN_DIR

alias btc="$PROJECT_BITCOIN_DIR/src/./bitcoin-cli -regtest"
echo "btc = $PROJECT_BITCOIN_DIR/src/./bitcoin-cli -regtest"

alias btcd="$PROJECT_BITCOIN_DIR/src/./bitcoind -regtest"
echo "btcd = $PROJECT_BITCOIN_DIR/src/./bitcoind -regtest"

btcd -daemon

echo "**************"
echo "Simplicity"
echo "**************"
echo "cd $PROJECT_DIR"
cd $PROJECT_DIR
echo "userDo \"git clone https://github.com/ElementsProject/simplicity.git\""
userDo "git clone https://github.com/ElementsProject/simplicity.git"
echo "userDo \"cabal update >> $INSTALL_LOG_DIR/simplicity_cabal_update.log\""
userDo "cabal update >> $INSTALL_LOG_DIR/simplicity_cabal_update"
echo "userDo \"cabal install bech32-1.0.2 >> $INSTALL_LOG_DIR/simplicity_cabal_bech32.log\""
userDo "cabal install bech32-1.0.2 >> $INSTALL_LOG_DIR/simplicity_cabal_bech32.log"
echo "userDo \"cabal install unification-fd cereal lens-family-2.0.0 SHA MemoTrie >> $INSTALL_LOG_DIR/simplicity_cabal_install.log\""
userDo "cabal install unification-fd cereal lens-family-2.0.0 SHA MemoTrie >> $INSTALL_LOG_DIR/simplicity_cabal_install.log"
echo "cd $PROJECT_SIMPLICITY_DIR"
cd $PROJECT_SIMPLICITY_DIR
echo "userDo \"git checkout 2867955c0c93418f45ffe8ea0a7b1277b785fdc4\""
userDo "git checkout 2867955c0c93418f45ffe8ea0a7b1277b785fdc4"
echo "userDo \"curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh\""
userDo "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
echo "userDo \"source /home/$PROJECT_USER/.cargo/env\""
userDo "source /home/$PROJECT_USER/.cargo/env"
echo "mkdir $PROJECT_HAL_DIR"
mkdir $PROJECT_HAL_DIR
echo "chmod 0755 $PROJECT_HAL_DIR && chown $PROJECT_USER $PROJECT_HAL_DIR"
chmod 0755 $PROJECT_HAL_DIR && chown $PROJECT_USER $PROJECT_HAL_DIR
echo "cd $PROJECT_HAL_DIR"
cd $PROJECT_HAL_DIR
echo "userDo \"wget https://github.com/stevenroose/hal/releases/download/v0.6.1/hal-0.6.1-vendored.tar.gz\""
userDo "wget https://github.com/stevenroose/hal/releases/download/v0.6.1/hal-0.6.1-vendored.tar.gz"
userDo "tar xzf hal-0.6.1-vendored.tar.gz"

echo "userDo \"cargo install hal  >> $INSTALL_LOG_DIR/hal_install.log\""
userDo "cargo install hal  >> $INSTALL_LOG_DIR/hal_install.log"

echo "mkdir -m 0755 /nix && chown $PROJECT_USER /nix"
mkdir -m 0755 /nix && chown $PROJECT_USER /nix
echo "userDo \"curl https://nixos.org/nix/install | sh\""
userDo "curl https://nixos.org/nix/install | sh"
echo "userDo . /home/$PROJECT_USER/.nix-profile/etc/profile.d/nix.sh"
userDo . /home/$PROJECT_USER/.nix-profile/etc/profile.d/nix.sh
echo "cd $PROJECT_SIMPLICITY_DIR"
cd $PROJECT_SIMPLICITY_DIR
echo "userDo \"nix-shell -p \"(import ./default.nix {}).haskellPackages.ghcWithPackages (pkgs: with pkgs; [Simplicity bech32])\"\"" 
userDo "nix-shell -p \"(import ./default.nix {}).haskellPackages.ghcWithPackages (pkgs: with pkgs; [Simplicity bech32])\""

echo "**************"
echo "Elements"
echo "**************"
echo "cd $PROJECT_ELEMENTS_DIR"
cd $PROJECT_ELEMENTS_DIR
echo "userDo ./autogen.sh" 
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
echo "cd $PROJECT_ELEMENTS_DIR/contrib/assets_tutorial"
cd $PROJECT_ELEMENTS_DIR/contrib/assets_tutorial

echo "mkdir $USER_BITCOIN_DIR" 
mkdir $USER_BITCOIN_DIR
echo "chmod 0755 $USER_BITCOIN_DIR && chown $PROJECT_USER $USER_BITCOIN_DIR"
chmod 0755 $USER_BITCOIN_DIR && chown $PROJECT_USER $USER_BITCOIN_DIR
cp ./bitcoin.conf $BITCOIN_DIR/bitcoin.conf

echo "mkdir $USER_ALICE_DIR"
mkdir $USER_ALICE_DIR
echo "chmod 0755 $USER_ALICE_DIR && chown $PROJECT_USER $USER_ALICE_DIR"
chmod 0755 $USER_ALICE_DIR && chown $PROJECT_USER $USER_ALICE_DIR
cp ./elements1.conf $USER_ALICE_DIR/elements.conf

echo "mkdir $USER_BOB_DIR"
mkdir $USER_BOB_DIR
echo "chmod 0755 $USER_BOB_DIR && chown $PROJECT_USER $USER_BOB_DIR"
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
echo "userDo ALICE_MINER_ADDRESS=$(alice-cli getnewaddress)"
userDo ALICE_MINER_ADDRESS=$(alice-cli getnewaddress)
echo "ALICE_MINER_ADDRESS=$ALICE_MINER_ADDRESS" >> $PROJECT_CONF
echo "echo \"ALICE_MINER_ADDRESS = \$ALICE_MINER_ADDRESS\"" >> $PROJECT_CONF

echo "userDo ALICE_RECEIVER_ADDRESS=$(alice-cli getnewaddress)" 
userDo ALICE_RECEIVER_ADDRESS=$(alice-cli getnewaddress)
echo "ALICE_RECEIVER_ADDRESS=$ALICE_RECEIVER_ADDRESS" >> $PROJECT_CONF
echo "echo \"ALICE_RECEIVER_ADDRESS = \$ALICE_RECEIVER_ADDRESS\"" >> $PROJECT_CONF

echo "userDo BOB_RECEIVER_ADDRESS=$(bob-cli getnewaddress)"
userDo BOB_RECEIVER_ADDRESS=$(bob-cli getnewaddress)
echo "BOB_RECEIVER_ADDRESS=$BOB_RECEIVER_ADDRESS" >> $PROJECT_CONF
echo "echo \"BOB_RECEIVER_ADDRESS = \$BOB_RECEIVER_ADDRESS\"" >> $PROJECT_CONF

echo "ALICE_MINER_ADDRESS = $ALICE_MINER_ADDRESS"
echo "ALICE_RECEIVER_ADDRESS = $ALICE_RECEIVER_ADDRESS"
echo "BOB_RECEIVER_ADDRESS = $BOB_RECEIVER_ADDRESS"

echo "**************"
echo "chmod +x"
echo "**************"
echo "cd $INSTALL_DIR"
cd $INSTALL_DIR
echo "chmod +x $INSTALL_DIR/elementsProjectStart.sh"
chmod +x $INSTALL_DIR/elementsProjectStart.sh
echo "chmod +x $INSTALL_DIR/elementsProjectStop.sh"
chmod +x $INSTALL_DIR/elementsProjectStop.sh
echo "chmod +x $INSTALL_DIR/test_transaction_simple.sh"
chmod +x $INSTALL_TEST_DIR/test_transaction_simple.sh

echo "cd $INSTALL_LOG_DIR" 
cd $INSTALL_LOG_DIR
ls -al
