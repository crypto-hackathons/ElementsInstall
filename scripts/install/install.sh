#!/bin/bash


function sourceForUser()
{	
	PROJECT_CONF="../../conf/elementsProject.conf"
	export USER_CONF="/home/$1/.elementsProject_$2_$3.conf"	

	if [ -f "$USER_CONF" ]
   then   
	    echo "# rm $USER_CONF"
	    rm $USER_CONF
    fi
    echo "# source $PROJECT_CONF $1 root $3 >> $USER_CONF"
	source $PROJECT_CONF $1 root $3 >> $USER_CONF
	
	echo "# chmod 0755 $USER_CONF && chown $USER $USER_CONF"
	chmod 0755 $USER_CONF && chown $USER $USER_CONF
	echo "# chmod +x $USER_CONF" 
	chmod +x $USER_CONF
}
echo ""
echo ""
echo ""
echo "**************"
echo "The full install take around 2h"
echo "**************"
echo ""
echo ""
echo ""   	
echo "**************"
echo "Configure"
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
echo "# ./install.sh -u ncantu -a $USER -k $APT -b $BERKELEY_DB -s $BITCOIN -n $NIX -e $ELEMENTS -p $PERSONAS -v =$ENVIRONNEMENT"
echo "USER=$USER"
echo "APT=$APT"
echo "BERKELEY_DB=$BERKELEY_DB"
echo "BITCOIN=$BITCOIN"
echo "NIX=$NIX"
echo "ELEMENTS=$ELEMENTS"
echo "PERSONAS=$PERSONAS"
echo "ENVIRONNEMENT=$ENVIRONNEMENT"

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
   		echo ""
   		echo ""
   		echo ""
		echo "**************"
		echo "Apt install"
		echo "The full install take around 2h"
		echo "This part take around 10min"
		echo "**************"
		suDoLog $INSTALL_DIR "apt-get install -y apt-utils" "apt_install"
		suDoLog $INSTALL_DIR "apt-get update -y" "apt_update" "apt_update"
		suDoLog $INSTALL_DIR "apt-get upgrade -y" "apt_upgrade" "apt_upgrade"
		suDoLog $INSTALL_DIR "apt-get install -y $APT_LIST" "apt_install"
		suDoLog $INSTALL_DIR "apt-get update -y --fix-missing" "apt_missing"
fi
if [ "$BERKELEY_DB" == "yes" ]
   then    		
   		echo ""
   		echo ""
   		echo ""
		echo "**************"
		echo "Berkeley DB install"
		echo "The full install take around 2h"
		echo "This part take around 5min"
		echo "**************"
		userMkdir $USER "$PROJECT_DIR"
		userGitClone $USER "$PROJECT_DIR" "https://github.com/ElementsProject/elements.git" "elements_gitClone" "$PROJECT_ELEMENTS_DIR"
		suDoLog "$PROJECT_ELEMENTS_DIR" "$PROJECT_ELEMENTS_DIR/contrib/install_db4.sh $DB4_INSTALL_PATH" "db4_install"
fi
if [ "$BITCOIN" == "yes" ]
   then    		
   		echo ""
   		echo ""
   		echo ""
		echo "**************"
		echo "Bitcoin install"
		echo "The full install take around 2h"
		echo "This part take around 40min"
		echo "**************"		
		userGitClone $USER "$PROJECT_DIR" "https://github.com/roconnor-blockstream/bitcoin.git" "bitcoin_install" "$PROJECT_BITCOIN_DIR"
		userGitChekout $USER "$PROJECT_BITCOIN_DIR" $PROJECT_BITCOIN_BRANCH
		userDoLog $USER "$PROJECT_BITCOIN_DIR" "$PROJECT_BITCOIN_DIR/./autogen.sh" "bitcoin_install"
		userDoLog $USER "$PROJECT_BITCOIN_DIR" "$BITCOIN_CONFIGURE" "bitcoin_install"
		suDoLog "$PROJECT_BITCOIN_DIR" make "bitcoin_install"
fi
if [ "$SIMPLICITY" == "yes" ]
   then   
   		echo ""
   		echo ""
   		echo ""
		echo "**************"
		echo "Simplicity install"
		echo "The full install take around 2h"
		echo "This part take around 5min"
		echo "**************"
		userGitClone $USER "$PROJECT_DIR" "https://github.com/ElementsProject/simplicity.git" "simplicity_install" "$PROJECT_SIMPLICITY_DIR"
		userGitChekout $USER "$PROJECT_SIMPLICITY_DIR" "$PROJECT_SIMPLICITY_BRANCH"
		userDoLog $USER "$PROJECT_DIR" "cabal update" "simplicity_install"		
		userDoLog $USER "$PROJECT_DIR" "cabal install bech32-1.0.2 unification-fd cereal lens-family-2.0.0 SHA MemoTrie" "simplicity_install"
		userDoLog $USER "$PROJECT_SIMPLICITY_DIR" "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs >> sh.rustup.rs"
		userDo $USER "$PROJECT_SIMPLICITY_DIR" "sh sh.rustup.rs -y"
		userDo $USER "$PROJECT_SIMPLICITY_DIR" "source /home/$USER/.cargo/env"
		userMkdir $USER "$PROJECT_HAL_DIR"		
		userWgetTarxzf $USER "$PROJECT_HAL_DIR" "https://github.com/stevenroose/hal/releases/download/v0.6.1/hal-0.6.1-vendored.tar.gz" "hal-0.6.1-vendored.tar.gz"
		userDoLog $USER "$PROJECT_HAL_DIR" "source /home/$USER/.cargo/env && cargo install hal" "simplicity_install"
fi
if [ "$NIX" == "yes" ]
   then
   		echo ""
   		echo ""
   		echo ""
		echo "**************"
		echo "Nix install"
		echo "The full install take around 2h"
		echo "This part take around 5min"
		echo "**************"
		userMkdir $USER "$PROJECT_NIX_DIR"		
		userDoLog $USER "$PROJECT_DIR" "curl https://nixos.org/nix/install | sh"		
		userDo $USER "$PROJECT_DIR" ". /home/$PROJECT_USER/.nix-profile/etc/profile.d/nix.sh"		
		simplicityenv
		
fi
if [ "$ELEMENTS" == "yes" ]
   then
   		echo ""
   		echo ""
   		echo ""
		echo "**************"
		echo "Elements install"
		echo "This part take around 40min"
		echo "**************"	
		userGitChekout $USER "$PROJECT_ELEMENTS_DIR" $PROJECT_ELEMENTS_BRANCH			
		userDo $USER "$PROJECT_ELEMENTS_DIR" "$PROJECT_ELEMENTS_DIR/./autogen.sh"		
		userDoLog $USER "$PROJECT_ELEMENTS_DIR" "$ELEMENTS_CONFIGURE" "elements_install"
		suDoLog  "$PROJECT_ELEMENTS_DIR" "make" "elements_install"
		suDoLog  "$PROJECT_ELEMENTS_DIR" "make install" "elements_install"
fi
if [ "$PERSONAS" == "yes" ]
   then
   		echo ""
   		echo ""
   		echo ""
		echo "**************"
		echo "Personas install"
		echo "The full install take around 2h"
		echo "This part take around 1min"
		echo "**************"		
		userMkdir $USER "$USER_BITCOIN_DIR"
		
		echo "regtest=$PROJECT_BITCOIN_REGTEST
daemon=$PROJECT_BITCOIN_DAEMON
txindex=$PROJECT_BITCOIN_TXINDEX
regtest.rpcport=$PROJECT_BITCOIN_REGTEST_RPC_PORT
regtest.port=$PROJECT_BITCOIN_REGTEST_PORT
rpcuser=$PROJECT_BITCOIN_REGTEST_RPC_USER
rpcpassword=password$PROJECT_BITCOIN_REGTEST_RPC_PASSWORD" >> $USER_BITCOIN_CONF

		echo "# chmod 0755 $USER_BITCOIN_CONF && chown $USER $USER_BITCOIN_CONF"
		chmod 0755 $USER_BITCOIN_CONF && chown $USER $USER_BITCOIN_CONF
		echo cat $USER_BITCOIN_CONF
		
		echo "# nohup $PROJECT_BITCOIN_DIR/src/./bitcoind -datadir=$USER_BITCOIN_DIR &>/dev/null &"
		btcd
		
		echo "# personaCreate $PROJECT_ELEMENTS_REGTEST_RPC_USER_ALICE $PROJECT_ELEMENTS_REGTEST_RPC_PASSWORD_ALICE $PROJECT_ELEMENTS_REGTEST_RPC_PORT_ALICE $PROJECT_ELEMENTS_REGTEST_PORT_ALICE $PROJECT_ELEMENTS_REGTEST_PORT_LOCAL_ALICE $PROJECT_ELEMENTS_INITIAL_FREE_COINS_ALICE $USER_ALICE_NAME"
		personaCreate $PROJECT_ELEMENTS_REGTEST_RPC_USER_ALICE $PROJECT_ELEMENTS_REGTEST_RPC_PASSWORD_ALICE $PROJECT_ELEMENTS_REGTEST_RPC_PORT_ALICE $PROJECT_ELEMENTS_REGTEST_PORT_ALICE $PROJECT_ELEMENTS_REGTEST_PORT_LOCAL_ALICE $PROJECT_ELEMENTS_INITIAL_FREE_COINS_ALICE $USER_ALICE_NAME
		
		echo "# personaCreate $PROJECT_ELEMENTS_REGTEST_RPC_USER_BOB $PROJECT_ELEMENTS_REGTEST_RPC_PASSWORD_BOB $PROJECT_ELEMENTS_REGTEST_RPC_PORT_BOB $PROJECT_ELEMENTS_REGTEST_PORT_BOB $PROJECT_ELEMENTS_REGTEST_PORT_LOCAL_BOB $PROJECT_ELEMENTS_INITIAL_FREE_COINS_BOB $USER_BOB_NAME"	
		personaCreate $PROJECT_ELEMENTS_REGTEST_RPC_USER_BOB $PROJECT_ELEMENTS_REGTEST_RPC_PASSWORD_BOB $PROJECT_ELEMENTS_REGTEST_RPC_PORT_BOB $PROJECT_ELEMENTS_REGTEST_PORT_BOB $PROJECT_ELEMENTS_REGTEST_PORT_LOCAL_BOB $PROJECT_ELEMENTS_INITIAL_FREE_COINS_BOB $USER_BOB_NAME
			
		chmodx "$INSTALL_DIR/../elementsProjectStart.sh"
		chmodx "$INSTALL_DIR/../elementsProjectStop.sh"
		chmodx "$INSTALL_DIR/../../test/test_transaction_simple.sh"
		
		exit
fi
echo ""
echo ""
echo ""
cat $USER_CONF" >> $INSTALL_DIR/result.log
ls -al" >> $INSTALL_DIR/result.log
ls -al" >> $INSTALL_DIR/result.log

echo "# cat "result.log"
