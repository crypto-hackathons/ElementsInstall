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
suDoLog "apt-get install -y git apt-utils libzmq5-dev build-essential libtool autotools-dev autoconf pkg-config libssl-dev libboost-all-dev libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler imagemagick librsvg2-bin libqrencode-dev autoconf openssl libssl-dev libevent-dev libminiupnpc-dev jq haskell-platform xz-utils autotools-dev automake g++ gpp pkg-config libdb++-dev libboost-all-dev libncurses-dev make openjdk-11-jre openjdk-11-jdk doxygen" "apt_install"
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
echo "Bitcoin install"
echo "**************"
allCd $1 "$PROJECT_DIR"
userGitClone $1 "https://github.com/roconnor-blockstream/bitcoin.git" "bitcoin_gitClone" "$PROJECT_BITCOIN_DIR"
allCd $1 "$PROJECT_BITCOIN_DIR"
userGitChekout $1 "simplicity"

exit
userDoLog $1 "./autogen.sh" "bitcoin_autogen"
userDoLog $1 "./configure BDB_LIBS=\"-L${BDB_PREFIX}/lib -ldb_cxx-4.8\" BDB_CFLAGS=\"-I${BDB_PREFIX}/include\" --disable-dependency-tracking --with-gui=no --disable-test --disable-bench --disable-jni" "bitcoin_configure"
suDo "make" "bitcoin_make"
allCd $1 "$PROJECT_BITCOIN_DIR"
suDo "btcd -daemon"

echo "**************"
echo "Simplicity install"
echo "**************"
allCd $1 "$PROJECT_DIR"
userGitClone $1 "https://github.com/ElementsProject/simplicity.git" "simplicity_gitClone" "$PROJECT_SIMPLICITY_DIR"
userDoLog $1 "cabal update" "simplicity_cabal_update"

userDoLog $1 "cabal install bech32-1.0.2 unification-fd cereal lens-family-2.0.0 SHA MemoTrie" "simplicity_cabal_install_lib"
userDoLog $1 "cabal install" "simplicity_cabal_install"

allCd $1 "$PROJECT_SIMPLICITY_DIR"

userGitChekout $1 "2867955c0c93418f45ffe8ea0a7b1277b785fdc4"
useDo $1 "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"

userDo $1 "source /home/$PROJECT_USER/.cargo/env"

userMkdir "$PROJECT_HAL_DIR"

allCd $1 "$PROJECT_HAL_DIR"

userWgetTarxzf $1 "https://github.com/stevenroose/hal/releases/download/v0.6.1/hal-0.6.1-vendored.tar.gz" "hal-0.6.1-vendored.tar.gz"

userDoLog $1 "cargo install hal" "hal_install"

echo "**************"
echo "Nix install"
echo "**************"
userMkdir $1 "$PROJECT_NIX_DIR"

userDo $1 "curl https://nixos.org/nix/install | sh"

userDo $1 ". /home/$PROJECT_USER/.nix-profile/etc/profile.d/nix.sh"

allCd $1 "$PROJECT_SIMPLICITY_DIR"

userDo $1 "nix-shell -p \"(import ./default.nix {}).haskellPackages.ghcWithPackages (pkgs: with pkgs; [Simplicity bech32])\""

echo "**************"
echo "Elements install"
echo "**************"

allCd $1 "$PROJECT_ELEMENTS_DIR"

userDo $1 "$PROJECT_ELEMENTS_DIR./autogen.sh"

userDoLog $1  "./configure BDB_LIBS=\"-L${BDB_PREFIX}/lib -ldb_cxx-4.8\" BDB_CFLAGS=\"-I${BDB_PREFIX}/include\" --disable-dependency-tracking --with-gui=no --disable-test --disable-bench" "elements_congigure"

suDoLog "make" "element_make"
suDoLog "make install" "elements_make_install"
suDo "which elementsd"

echo "**************"
echo "Personas install"
echo "**************"
allCd $1 "$PROJECT_ELEMENTS_DIR/contrib/assets_tutorial"

userMkdir $1 "$USER_BITCOIN_DIR"
userDo $1 "cp ./bitcoin.conf $BITCOIN_DIR/bitcoin.conf"

userMkdir $1 "$USER_ALICE_DIR"
userDo $1 "cp ./elements1.conf $USER_ALICE_DIR/elements.conf"

userMkdir $1 "$USER_BOB_DIR"
userDo $1 "cp ./elements2.conf $USER_BOB_DIR/elements.conf"

echo "**************"
echo "Start deamons"
echo "**************"
userDo $1 "b-dae"
userDo $1 "alice-dae"
userDo $1 "bob-dae"

echo "**************"
echo "Personas address add to conf"
echo "**************"
echo "# ALICE_MINER_ADDRESS=$(alice-cli getnewaddress)"
ALICE_MINER_ADDRESS=$(alice-cli getnewaddress)
echo "ALICE_MINER_ADDRESS=$ALICE_MINER_ADDRESS" >> $PROJECT_CONF

echo "# ALICE_RECEIVER_ADDRESS=$(alice-cli getnewaddress)"
ALICE_RECEIVER_ADDRESS=$(alice-cli getnewaddress)
echo "ALICE_RECEIVER_ADDRESS=$ALICE_RECEIVER_ADDRESS" >> $PROJECT_CONF

echo "# BOB_RECEIVER_ADDRESS=$(bob-cli getnewaddress)"
BOB_RECEIVER_ADDRESS=$(bob-cli getnewaddress)
echo "BOB_RECEIVER_ADDRESS=$BOB_RECEIVER_ADDRESS" >> $PROJECT_CONF

echo "# ALICE_MINER_ADDRESS = $ALICE_MINER_ADDRESS" 
ALICE_MINER_ADDRESS = $ALICE_MINER_ADDRESS
echo "ALICE_MINER_ADDRESS=$ALICE_MINER_ADDRESS" >> $PROJECT_CONF

echo "**************"
echo "Activation"
echo "**************"
allCd $1 "$INSTALL_DIR"
chmodx "$INSTALL_DIR/elementsProjectStart.sh"
chmodx "$INSTALL_DIR/elementsProjectStop.sh"
chmodx "$INSTALL_DIR/../../test/test_transaction_simple.sh"

allCd $1 "$INSTALL_LOG_DIR"
userDo $1 "ls -al"

