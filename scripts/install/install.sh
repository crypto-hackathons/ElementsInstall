#!/bin/bash

clear

USER=$USER
APT="yes"
BERKELEY_DB="yes"
BITCOIN="yes"
NIX="yes"
ELEMENTS="yes"
PERSONAS="yes"

while getopts u:a:k:b:s:n:e:p: option
	do
		case "${option}"
		in
			u) USER=${OPTARG};;
			a) APT=${OPTARG};;
			k) BERKELEY_DB=${OPTARG};;
			b) BITCOIN=${OPTARG};;
			s) SIMPLICITY=${OPTARG};;
			n) NIX=${OPTARG};;
			e) ELEMENTS=${OPTARG};;
			p) PERSONAS=${OPTARG};;
		esac
	done

if [ $USER == "root" ]
   then
   		echo "USER must not be root"
   		exit
fi
echo "**************"
echo "Options"
echo "**************"
echo "USER=$USER"
echo "APT=$APT"
echo "BERKELEY_DB=$BERKELEY_DB"
echo "BITCOIN=$BITCOIN"
echo "NIX=$NIX"
echo "ELEMENTS=$ELEMENTS"
echo "PERSONAS=$PERSONAS"

echo "**************"
echo "Configure"
echo "**************"
source functions.sh
sourceForUser $USER "root"
su $USER -c "source functions.sh && sourceForUser $USER $USER"
echo "# echo \"run with $USER\""

echo "**************"
echo "Install"
echo "**************"
echo "**************"
echo "Directory"
echo "**************"
if [ -d "$PROJECT_DIR" ]; then
	echo "$ echo \"$PROJECT_DIR exist\""
else
   echo "# mkdir $PROJECT_DIR"
   mkdir $PROJECT_DIR
   echo "# chmod 0755 $PROJECT_DIR && chown $USER $PROJECT_DIR"
   chmod 0755 $PROJECT_DIR && chown $USER $PROJECT_DIR
fi

if [ "$APT" == "yes" ]
   then 
		echo "**************"
		echo "Apt install"
		echo "**************"
		suDoLog "apt-get update -y" "apt_update"
		suDoLog "apt-get upgrade -y" "apt_upgrade"
		suDoLog "apt-get install -y git apt-utils $APT_LIST"
		suDoLog "apt-get update -y --fix-missing" "apt_missing"
fi
if [ "$BERKELEY_DB" == "yes" ]
   then 
		echo "**************"
		echo "Berkeley DB install"
		echo "**************"
		userMkdir $USER "$PROJECT_DIR"
		userGitClone $USER "$PROJECT_DIR" "https://github.com/ElementsProject/elements.git" "elements_gitClone" "$PROJECT_ELEMENTS_DIR"
		suDoLog "$PROJECT_ELEMENTS_DIR" "$PROJECT_ELEMENTS_DIR/contrib/install_db4.sh $DB4_INSTALL_PATH" "db4_install"
fi
if [ "$BITCOIN" == "yes" ]
   then 
		echo "**************"
		echo "Bitcoin install"
		echo "**************"		
		userGitClone $USER "$PROJECT_DIR" "https://github.com/roconnor-blockstream/bitcoin.git" "bitcoin_gitClone" "$PROJECT_BITCOIN_DIR"
		userGitChekout $USER "$PROJECT_BITCOIN_DIR" $PROJECT_BITCOIN_BRANCH
		userDoLog $USER "$PROJECT_BITCOIN_DIR" "$PROJECT_BITCOIN_DIR/./autogen.sh" "bitcoin_autogen"
		userDoLog $USER "$PROJECT_BITCOIN_DIR" "$BITCOIN_CONFIGURE" "bitcoin_configure"
		suDoLog "$PROJECT_BITCOIN_DIR" make "bitcoin_make"		
		suDo "nohup btcd -daemon &>/dev/null &"
fi
if [ "$SIMPLICITY" == "yes" ]
   then
		echo "**************"
		echo "Simplicity install"
		echo "**************"
		userGitClone $USER "$PROJECT_DIR" "https://github.com/ElementsProject/simplicity.git" "simplicity_gitClone" "$PROJECT_SIMPLICITY_DIR"
		userGitChekout $USER "$PROJECT_SIMPLICITY_DIR" "$PROJECT_SIMPLICITY_BRANCH"
		userDoLog $USER "$PROJECT_DIR" "cabal update" "simplicity_cabal_update"		
		userDoLog $USER "$PROJECT_DIR" "cabal install bech32-1.0.2 unification-fd cereal lens-family-2.0.0 SHA MemoTrie" "simplicity_cabal_install_lib"
		userDoLog $USER "$PROJECT_SIMPLICITY_DIR" "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs >> sh.rustup.rs"
		userDo $USER "$PROJECT_SIMPLICITY_DIR" "sh sh.rustup.rs -y"
		userDo $USER "$PROJECT_SIMPLICITY_DIR" "source /home/$USER/.cargo/env"		
		userMkdir $USER "$PROJECT_HAL_DIR"		
		userWgetTarxzf $USER "$PROJECT_HAL_DIR" "https://github.com/stevenroose/hal/releases/download/v0.6.1/hal-0.6.1-vendored.tar.gz" "hal-0.6.1-vendored.tar.gz"
		userDoLog $USER "$PROJECT_HAL_DIR" "cargo install hal" "hal_install"
		
		exit;
fi
exit
if [ "$NIX" == "yes" ]
   then
		echo "**************"
		echo "Nix install"
		echo "**************"
		userMkdir $USER "$PROJECT_NIX_DIR"		
		userDo $USER "$PROJECT_DIR" "curl https://nixos.org/nix/install | sh"		
		userDo $USER "$PROJECT_DIR" ". /home/$PROJECT_USER/.nix-profile/etc/profile.d/nix.sh"		
		userDo $USER "$PROJECT_SIMPLICITY_DIR" "nix-shell -p \"(import ./default.nix {}).haskellPackages.ghcWithPackages (pkgs: with pkgs; [Simplicity bech32])\""
fi
if [ "$ELEMENTS" == "yes" ]
   then
		echo "**************"
		echo "Elements install"
		echo "**************"		
		userDo $USER "$PROJECT_ELEMENTS_DIR" "$PROJECT_ELEMENTS_DIR/./autogen.sh"		
		userDoLog $USER "$PROJECT_ELEMENTS_DIR" "$PROJECT_ELEMENTS_DIR/./configure BDB_LIBS=\"-L${BDB_PREFIX}/lib -ldb_cxx-4.8\" BDB_CFLAGS=\"-I${BDB_PREFIX}/include\" --disable-dependency-tracking --with-gui=no --disable-test --disable-bench" "elements_congigure"
		suDoLog  "$PROJECT_ELEMENTS_DIR" "make" "element_make"
		suDoLog  "$PROJECT_ELEMENTS_DIR" "make install" "elements_make_install"
		suDo  "$PROJECT_ELEMENTS_DIR" "which elementsd"
fi
if [ "$PERSONAS" == "yes" ]
   then
		echo "**************"
		echo "Personas install"
		echo "**************"		
		userMkdir $USER "$USER_BITCOIN_DIR"
		userDo $USER "$PROJECT_ELEMENTS_DIR/contrib/assets_tutorial" "cp $USER_BITCOIN_DIR/bitcoin.conf $BITCOIN_DIR/bitcoin.conf"
		userMkdir $USER "$USER_ALICE_DIR"
		userDo $USER "$PROJECT_ELEMENTS_DIR/contrib/assets_tutorial"  "cp $USER_BITCOIN_DIR/elements1.conf $USER_ALICE_DIR/elements.conf"
		userMkdir $USER "$USER_BOB_DIR"
		userDo $USER "$PROJECT_ELEMENTS_DIR/contrib/assets_tutorial"  "cp $USER_BITCOIN_DIR/elements2.conf $USER_BOB_DIR/elements.conf"
		
		userDo $USER "$PROJECT_DIR" "b-dae"
		userDo $USER "$PROJECT_DIR" "alice-dae"
		userDo $USER "$PROJECT_DIR" "bob-dae"
		
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
fi
echo "**************"
echo "Activation"
echo "**************"
allCd $USER "$INSTALL_DIR"
chmodx "$INSTALL_DIR/elementsProjectStart.sh"
chmodx "$INSTALL_DIR/elementsProjectStop.sh"
chmodx "$INSTALL_DIR/../../test/test_transaction_simple.sh"
userDo $USER "$INSTALL_LOG_DIR" "ls -al"
