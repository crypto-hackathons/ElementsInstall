#!/bin/bash


function sourceForUser()
{	
	PROJECT_CONF="../../conf/elementsProject.conf"
	export USER_CONF="/home/$1/.elementsProject_$2_$3.conf"	

	if [ -f "$USER_CONF" ]
   then   
	    echo "# rm $USER_CONF"
	    rm -y $USER_CONF
    fi
    echo "# source $PROJECT_CONF $1 root $3 >> $USER_CONF"
	source $PROJECT_CONF $1 root $3 >> $USER_CONF
	
	echo "# chmod 0755 $USER_CONF && chown $USER $USER_CONF"
	chmod 0755 $CONF_FILE && chown $USER $CONF_FILE
	echo "# chmod +x $CONF_FILE" 
	chmod +x $CONF_FILE
}
clear
echo "**************"
echo "The install take around 2h"
echo "**************"
echo "**************"
echo "Options"
echo "**************"
USER=$USER
APT="yes"
BERKELEY_DB="yes"
BITCOIN="yes"
NIX="yes"
ELEMENTS="yes"
PERSONAS="yes"
ENVIRONNEMENT="regtest"

while getopts u:a:k:b:s:n:e:p:v: option
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
			v) ENVIRONNEMENT=${OPTARG};;
		esac
	done

if [ $USER == "root" ]
   then
   		echo "USER must not be root"
   		exit
fi
echo "USER=$USER"
echo "APT=$APT"
echo "BERKELEY_DB=$BERKELEY_DB"
echo "BITCOIN=$BITCOIN"
echo "NIX=$NIX"
echo "ELEMENTS=$ELEMENTS"
echo "PERSONAS=$PERSONAS"
echo "ENVIRONNEMENT=$ENVIRONNEMENT"

echo "**************"
echo "Configure"
echo "**************"
HERE=`pwd`
sourceForUser $USER "root" $ENVIRONNEMENT
su $USER -c "cd $HERE && source functions.sh && sourceForUser $USER $USER $ENVIRONNEMENT"

echo "# echo \"run with $USER\""

if [ -d "$PROJECT_DIR" ]; then
	echo "# echo \"$PROJECT_DIR exist\""
else
   echo "# mkdir $PROJECT_DIR"
   mkdir $PROJECT_DIR
   echo "# chmod 0755 $PROJECT_DIR && chown $USER $PROJECT_DIR"
   chmod 0755 $PROJECT_DIR && chown $USER $PROJECT_DIR
fi

if [ "$APT" == "yes" ]
   then 
   		clear
		echo "**************"
		echo "Apt install"
		echo "**************"
		suDoLog ./ "apt-get update -y" "apt_update"
		suDoLog ./ "apt-get upgrade -y" "apt_upgrade"
		suDoLog ./ "apt-get install -y git apt-utils $APT_LIST"
		suDoLog ./ "apt-get update -y --fix-missing" "apt_missing"
fi
if [ "$BERKELEY_DB" == "yes" ]
   then 
   		clear
		echo "**************"
		echo "Berkeley DB install"
		echo "**************"
		userMkdir $USER "$PROJECT_DIR"
		userGitClone $USER "$PROJECT_DIR" "https://github.com/ElementsProject/elements.git" "elements_gitClone" "$PROJECT_ELEMENTS_DIR"
		suDoLog "$PROJECT_ELEMENTS_DIR" "$PROJECT_ELEMENTS_DIR/contrib/install_db4.sh $DB4_INSTALL_PATH" "db4_install"
fi
if [ "$BITCOIN" == "yes" ]
   then 
   		clear
		echo "**************"
		echo "Bitcoin install"
		echo "**************"		
		userGitClone $USER "$PROJECT_DIR" "https://github.com/roconnor-blockstream/bitcoin.git" "bitcoin_gitClone" "$PROJECT_BITCOIN_DIR"
		userGitChekout $USER "$PROJECT_BITCOIN_DIR" $PROJECT_BITCOIN_BRANCH
		userDoLog $USER "$PROJECT_BITCOIN_DIR" "$PROJECT_BITCOIN_DIR/./autogen.sh" "bitcoin_autogen"
		userDoLog $USER "$PROJECT_BITCOIN_DIR" "$BITCOIN_CONFIGURE" "bitcoin_configure"
		suDoLog "$PROJECT_BITCOIN_DIR" make "bitcoin_make"
fi
if [ "$SIMPLICITY" == "yes" ]
   then
   		clear
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
		userDoLog $USER "$PROJECT_HAL_DIR" "source /home/$USER/.cargo/env && cargo install hal" "hal_install"
fi
if [ "$NIX" == "yes" ]
   then
   		clear
		echo "**************"
		echo "Nix install"
		echo "**************"
		userMkdir $USER "$PROJECT_NIX_DIR"		
		userDoLog $USER "$PROJECT_DIR" "curl https://nixos.org/nix/install | sh"		
		userDo $USER "$PROJECT_DIR" ". /home/$PROJECT_USER/.nix-profile/etc/profile.d/nix.sh"		
		simplicityenv
		
fi
if [ "$ELEMENTS" == "yes" ]
   then
   		clear
		echo "**************"
		echo "Elements install"
		echo "**************"	
		userGitChekout $USER "$PROJECT_ELEMENTS_DIR" $PROJECT_ELEMENTS_BRANCH			
		userDo $USER "$PROJECT_ELEMENTS_DIR" "$PROJECT_ELEMENTS_DIR/./autogen.sh"		
		userDoLog $USER "$PROJECT_ELEMENTS_DIR" "$ELEMENTS_CONFIGURE" "elements_configure"
		suDoLog  "$PROJECT_ELEMENTS_DIR" "make" "element_make"
		suDoLog  "$PROJECT_ELEMENTS_DIR" "make install" "elements_make_install"
fi
if [ "$PERSONAS" == "yes" ]
   then
   		clear
		echo "**************"
		echo "Personas install"
		echo "**************"		
		userMkdir $USER "$USER_BITCOIN_DIR"
		userDo $USER "$PROJECT_ELEMENTS_DIR/contrib/assets_tutorial" "cp $PROJECT_ELEMENTS_DIR/contrib/assets_tutorial/bitcoin.conf  $USER_BITCOIN_DIR/bitcoin.conf"
		userMkdir $USER "$USER_ALICE_DIR"
		userDo $USER "$PROJECT_ELEMENTS_DIR/contrib/assets_tutorial"  "cp $PROJECT_ELEMENTS_DIR/contrib/assets_tutorial/elements1.conf $USER_ALICE_DIR/elements.conf"
		userMkdir $USER "$USER_BOB_DIR"
		userDo $USER "$PROJECT_ELEMENTS_DIR/contrib/assets_tutorial"  "cp $PROJECT_ELEMENTS_DIR/contrib/assets_tutorial/elements2.conf $USER_BOB_DIR/elements.conf"
			
		chmodx "$INSTALL_DIR/../elementsProjectStart.sh"
		chmodx "$INSTALL_DIR/../elementsProjectStop.sh"
		chmodx "$INSTALL_DIR/../../test/test_transaction_simple.sh"
				
		userDo $USER "$INSTALL_DIR/../" "$INSTALL_DIR/.././elementsProjectStart.sh -u $USER -v regtest"
		
		echo "$PROJECT_ELEMENTS_DIR/src/./elements-cli -datadir=$USER_BOB_DIR getnewaddress"
		$PROJECT_ELEMENTS_DIR/src/./elements-cli -datadir=$USER_BOB_DIR getnewaddress
		exit
		
		
		
		echo "# ALICE_MINER_ADDRESS=aliceGetNewAddress"
		ALICE_MINER_ADDRESS=aliceGetNewAddress
		echo "ALICE_MINER_ADDRESS=$ALICE_MINER_ADDRESS" >> $INSTALL_DIR/../../conf/personas.conf
				
		bobGetNewAddress
		echo bobGetNewAddress
		echo "# ALICE_RECEIVER_ADDRESS=$(bobGetNewAddress)"
		ALICE_RECEIVER_ADDRESS=aliceGetNewAddress
		echo "ALICE_RECEIVER_ADDRESS=$ALICE_RECEIVER_ADDRESS" >> $INSTALL_DIR/../../conf/personas.conf
		
		echo "# BOB_RECEIVER_ADDRESS=bobGetNewAddress"
		BOB_RECEIVER_ADDRESS=bobGetNewAddress
		echo "BOB_RECEIVER_ADDRESS=$BOB_RECEIVER_ADDRESS" >> $INSTALL_DIR/../../conf/personas.conf
		
		exit
fi
cat $CONF_FILE" >> $INSTALL_DIR/result.log
ls -al" >> $INSTALL_DIR/result.log
ls -al" >> $INSTALL_DIR/result.log

echo "# cat "result.log"
