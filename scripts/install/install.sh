#!/bin/bash

echo "**************"
echo "Configure"
echo "**************"
source ../../conf/elementsProject.conf $1

echo "**************"
echo "Directory"
echo "**************"
userMkdir $1 $PROJECT_DIR

echo "**************"
echo "Apt install"
echo "**************"
suDoLog "apt-get update -y" "apt_update"
suDoLog "apt-get upgrade -y" "apt_upgrade"
suDoLog "apt-get install -y git apt-utils libzmq5-dev build-essential libtool autotools-dev autoconf pkg-config libssl-dev libboost-all-dev libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler imagemagick librsvg2-bin libqrencode-dev autoconf openssl libssl-dev libevent-dev libminiupnpc-dev jq haskell-platform xz-utils autotools-dev automake g++ gpp pkg-config libdb++-dev libboost-all-dev libncurses-dev make doxygen" "apt_install"
suDoLog "apt-get update -y --fix-missing" "apt_missing"

echo "**************"
echo "Berkeley DB install"
echo "**************"
userMkdir $1 "$PROJECT_DIR" 
allCd $1 "$PROJECT_DIR"
userGitClone $1 "https://github.com/ElementsProject/elements.git" "elements_gitClone" "$PROJECT_ELEMENTS_DIR"
allCd $1 "$PROJECT_ELEMENTS_DIR"
suDoLog "$PROJECT_ELEMENTS_DIR/contrib/install_db4.sh $DB4_INSTALL_PATH" "db4_install"

echo "**************"
echo "Bitcoin"
echo "**************"
allCd $1 "$PROJECT_DIR"
userGitClone $1 "https://github.com/roconnor-blockstream/bitcoin.git" "bitcoin_gitClone" "$PROJECT_BITCOIN_DIR"
allCd $1 "$PROJECT_BITCOIN_DIR"
userGitChekout $1 "simplicity"
userDoLog $1 "./autogen.sh" "bitcoin_autogen"
userDoLog $1 "./configure BDB_LIBS=\"-L${BDB_PREFIX}/lib -ldb_cxx-4.8\" BDB_CFLAGS=\"-I${BDB_PREFIX}/include\" --disable-dependency-tracking --with-gui=no --disable-test --disable-bench" "bitcoin_configure"
suDo "make" "bitcoin_make"
allCd $1 "$PROJECT_BITCOIN_DIR"
suDo "btcd -daemon"
exit

echo "**************"
echo "Simplicity"
echo "**************"
allCd $1 "$PROJECT_DIR"
userGitClone $1 "https://github.com/ElementsProject/simplicity.git" "simplicity_gitClone" "$PROJECT_SIMPLICITY_DIR"
userDoLog $1 "cabal update" "simplicity_cabal_update"

userDoLog $1 "cabal install bech32-1.0.2 unification-fd cereal lens-family-2.0.0 SHA MemoTrie" "simplicity_cabal_install_lib"
userDoLog $1 "cabal install" "simplicity_cabal_install"

allCd $1 "$PROJECT_SIMPLICITY_DIR"

useDo $1 "git checkout 2867955c0c93418f45ffe8ea0a7b1277b785fdc4"
useDo $1 "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"

userDo $1 "source /home/$PROJECT_USER/.cargo/env"

userMkdir "$PROJECT_HAL_DIR"

allCd $1 "$PROJECT_HAL_DIR"

userWgetTarxzf $1 "https://github.com/stevenroose/hal/releases/download/v0.6.1/hal-0.6.1-vendored.tar.gz" "hal-0.6.1-vendored.tar.gz"

userDoLog $1 "cargo install hal" "hal_install"

if [ -d "/nix" ]
then
    echo "/nix exist, rm"
    rm -rf /nix
fi

echo "mkdir -m 0755 /nix && chown $PROJECT_USER /nix"
mkdir -m 0755 /nix && chown $PROJECT_USER /nix

echo "userDo \"curl https://nixos.org/nix/install | sh\""
userDo "curl https://nixos.org/nix/install | sh"

echo "userDo \". /home/$PROJECT_USER/.nix-profile/etc/profile.d/nix.sh\""
userDo ". /home/$PROJECT_USER/.nix-profile/etc/profile.d/nix.sh"

echo "cd $PROJECT_SIMPLICITY_DIR"
cd $PROJECT_SIMPLICITY_DIR

echo "userDo \"nix-shell -p \"(import ./default.nix {}).haskellPackages.ghcWithPackages (pkgs: with pkgs; [Simplicity bech32])\"" 
userDo "nix-shell -p \"(import ./default.nix {}).haskellPackages.ghcWithPackages (pkgs: with pkgs; [Simplicity bech32])\""

echo "**************"
echo "Elements"
echo "**************"

echo "cd $PROJECT_ELEMENTS_DIR"
cd $PROJECT_ELEMENTS_DIR

echo "userDo ./autogen.sh" 
userDo ./autogen.sh

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

if [ -d "$USER_BITCOIN_DIR" ]
then
    echo "$USER_BITCOIN_DIR exist, rm"
    rm -rf $USER_BITCOIN_DIR
fi
echo "mkdir $USER_BITCOIN_DIR" 
mkdir $USER_BITCOIN_DIR
echo "chmod 0755 $USER_BITCOIN_DIR && chown $PROJECT_USER $USER_BITCOIN_DIR"
chmod 0755 $USER_BITCOIN_DIR && chown $PROJECT_USER $USER_BITCOIN_DIR
cp ./bitcoin.conf $BITCOIN_DIR/bitcoin.conf

if [ -d "$USER_ALICE_DIR" ]
then
    echo "$USER_ALICE_DIR exist, rm"
    rm -rf $USER_ALICE_DIR
fi
echo "mkdir $USER_ALICE_DIR"
mkdir $USER_ALICE_DIR
echo "chmod 0755 $USER_ALICE_DIR && chown $PROJECT_USER $USER_ALICE_DIR"
chmod 0755 $USER_ALICE_DIR && chown $PROJECT_USER $USER_ALICE_DIR
cp ./elements1.conf $USER_ALICE_DIR/elements.conf

if [ -d "$USER_BOB_DIR" ]
then
    echo "$USER_BOB_DIR exist, rm"
    rm -rf $USER_BOB_DIR
fi
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
echo "echo \"ALICE_MINER_ADDRESS = \"$ALICE_MINER_ADDRESS\"" >> $PROJECT_CONF

echo "userDo ALICE_RECEIVER_ADDRESS=$(alice-cli getnewaddress)" 
userDo ALICE_RECEIVER_ADDRESS=$(alice-cli getnewaddress)
echo "ALICE_RECEIVER_ADDRESS=$ALICE_RECEIVER_ADDRESS" >> $PROJECT_CONF
echo "echo \"ALICE_RECEIVER_ADDRESS = \"$ALICE_RECEIVER_ADDRESS\"" >> $PROJECT_CONF

echo "userDo BOB_RECEIVER_ADDRESS=$(bob-cli getnewaddress)"
userDo BOB_RECEIVER_ADDRESS=$(bob-cli getnewaddress)
echo "BOB_RECEIVER_ADDRESS=$BOB_RECEIVER_ADDRESS" >> $PROJECT_CONF
echo "echo \"BOB_RECEIVER_ADDRESS = \"$BOB_RECEIVER_ADDRESS\"" >> $PROJECT_CONF

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
