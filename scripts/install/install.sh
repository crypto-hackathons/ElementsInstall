#!/bin/bash

clear
source functions.sh

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
sourceForUser $USER "root"
sourceForUser $USER $USER

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
		allCd $USER "$PROJECT_DIR"
		userGitClone $USER "https://github.com/ElementsProject/elements.git" "elements_gitClone" "$PROJECT_ELEMENTS_DIR"
		allCd $USER "$PROJECT_ELEMENTS_DIR"
		suDoLog "$PROJECT_ELEMENTS_DIR/contrib/install_db4.sh $DB4_INSTALL_PATH" "db4_install"
fi
if [ "$BITCOIN" == "yes" ]
   then 
		echo "**************"
		echo "Bitcoin install"
		echo "**************"
		allCd $USER "$PROJECT_DIR"
		userGitClone $USER "https://github.com/roconnor-blockstream/bitcoin.git" "bitcoin_gitClone" "$PROJECT_BITCOIN_DIR"
		allCd $USER "$PROJECT_BITCOIN_DIR"
		userGitChekout $USER $PROJECT_BITCOIN_BRANCH
		userDoLog $USER "$PROJECT_BITCOIN_DIR/./autogen.sh" "bitcoin_autogen"
		allCd $USER "$PROJECT_BITCOIN_DIR"
		userDoLog $USER "$BITCOIN_CONFIGURE" "bitcoin_configure"
		allCd $USER "$PROJECT_BITCOIN_DIR"
		suDoLog make "bitcoin_make"		
		suDo "nohup btcd -daemon &>/dev/null &"
fi
if [ "$SIMPLICITY" == "yes" ]
   then
		echo "**************"
		echo "Simplicity install"
		echo "**************"
		allCd $USER "$PROJECT_DIR"
		userGitClone $USER "https://github.com/ElementsProject/simplicity.git" "simplicity_gitClone" "$PROJECT_SIMPLICITY_DIR"
		allCd $USER "$PROJECT_SIMPLICITY_DIR"
		userGitChekout $USER "$PROJECT_SIMPLICITY_BRANCH"
		allCd $USER "$PROJECT_DIR"
		userDoLog $USER "cabal update" "simplicity_cabal_update"		
		userDoLog $USER "cabal install bech32-1.0.2 unification-fd cereal lens-family-2.0.0 SHA MemoTrie" "simplicity_cabal_install_lib"
		userDoLog $USER "cabal install" "simplicity_cabal_install"
		
		allCd $USER "$PROJECT_SIMPLICITY_DIR"		
		
		useDo $USER "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
		
		userDo $USER "source /home/$PROJECT_USER/.cargo/env"
		
		userMkdir "$PROJECT_HAL_DIR"
		
		allCd $USER "$PROJECT_HAL_DIR"
		
		userWgetTarxzf $USER "https://github.com/stevenroose/hal/releases/download/v0.6.1/hal-0.6.1-vendored.tar.gz" "hal-0.6.1-vendored.tar.gz"
		
		userDoLog $USER "cargo install hal" "hal_install"
		
		exit;
fi
exit
if [ "$NIX" == "yes" ]
   then
		echo "**************"
		echo "Nix install"
		echo "**************"
		userMkdir $USER "$PROJECT_NIX_DIR"
		
		userDo $USER "curl https://nixos.org/nix/install | sh"
		
		userDo $USER ". /home/$PROJECT_USER/.nix-profile/etc/profile.d/nix.sh"
		
		allCd $USER "$PROJECT_SIMPLICITY_DIR"
		
		userDo $USER "nix-shell -p \"(import ./default.nix {}).haskellPackages.ghcWithPackages (pkgs: with pkgs; [Simplicity bech32])\""
fi
if [ "$ELEMENTS" == "yes" ]
   then
		echo "**************"
		echo "Elements install"
		echo "**************"
		
		allCd $USER "$PROJECT_ELEMENTS_DIR"
		
		userDo $USER "$PROJECT_ELEMENTS_DIR/./autogen.sh"
		
		userDoLog $USER "$PROJECT_ELEMENTS_DIR/./configure BDB_LIBS=\"-L${BDB_PREFIX}/lib -ldb_cxx-4.8\" BDB_CFLAGS=\"-I${BDB_PREFIX}/include\" --disable-dependency-tracking --with-gui=no --disable-test --disable-bench" "elements_congigure"
		
		suDoLog "make" "element_make"
		suDoLog "make install" "elements_make_install"
		suDo "which elementsd"
fi
if [ "$PERSONAS" == "yes" ]
   then
		echo "**************"
		echo "Personas install"
		echo "**************"
		allCd $USER "$PROJECT_ELEMENTS_DIR/contrib/assets_tutorial"
		
		userMkdir $USER "$USER_BITCOIN_DIR"
		userDo $USER "cp $USER_BITCOIN_DIR/bitcoin.conf $BITCOIN_DIR/bitcoin.conf"
		
		userMkdir $USER "$USER_ALICE_DIR"
		userDo $USER "cp $USER_BITCOIN_DIR/elements1.conf $USER_ALICE_DIR/elements.conf"
		
		userMkdir $USER "$USER_BOB_DIR"
		userDo $USER "cp $USER_BITCOIN_DIR/elements2.conf $USER_BOB_DIR/elements.conf"
		
		userDo $USER "b-dae"
		userDo $USER "alice-dae"
		userDo $USER "bob-dae"
		
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

allCd $USER "$INSTALL_LOG_DIR"
userDo $USER "ls -al"
