#!/bin/bash

function sourceForUser()
{	
    LIB_DIR="../../lib"
    CONF_DIR="../../conf"
    PROJECT_CONF="$CONF_DIR/elementsProject.conf"
    export USER_CONF="/home/$1/.elementsProject_$2_$3.conf"	

   if [ -f "$USER_CONF" ]
   then   
	    echo "# rm $USER_CONF"
	    rm $USER_CONF
    fi
    echo "# source $PROJECT_CONF $1 root $3 $LIB_DIR >> $USER_CONF"
    if [ $USER == "root" ]
   then   
            export USER_CONF="/home/$USER/.elementsProject_$2_$3.conf"
	    su $USER -c "cd $HERE && source $PROJECT_CONF $1 root $3 $LIB_DIR >> $USER_CONF"
   else 
           export USER_CONF="/home/$USER/.elementsProject_$2_$3.conf"
           cd $HERE && source $PROJECT_CONF root root $3 $LIB_DIR >> $USER_CONF
   fi
    userRights $USER $USER_CONF
    echo "# chmod +x $USER_CONF" 
    chmod +x $USER_CONF
}
echo "# "
echo "# "
echo "# "
echo "# **************"
echo "# The full install take around 2h"
echo "# **************"
echo "# "
echo "# "
echo "# "   	
echo "# **************"
echo "# Configure"
echo "# **************"
USER=$USER
APT="yes"
BERKELEY_DB="yes"
BITCOIN="yes"
NIX="yes"
ELEMENTS="yes"
PERSONAS="yes"
ENVIRONNEMENT="regtest"
NODES="yes"
WALLET="yes"

while getopts u:a:k:b:s:n:e:p:v:j:w:g: option
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
			j) NODES=${OPTARG};;
			w) WALLET=${OPTARG};;
			g) GREENADDRESS=${OPTARG};;
		esac
	done

if [ $USER == "root" ]
   then
   		echo "# echo \"USER must not be root\""
   		exit
fi
echo "# ./install.sh -u ncantu -a $USER -k $APT -b $BERKELEY_DB -s $BITCOIN -n $NIX -e $ELEMENTS -p $PERSONAS -v $ENVIRONNEMENT -j =$NODES -w $WALLET"
echo "# USER=$USER"
echo "# APT=$APT"
echo "# BERKELEY_DB=$BERKELEY_DB"
echo "# BITCOIN=$BITCOIN"
echo "# NIX=$NIX"
echo "# ELEMENTS=$ELEMENTS"
echo "# PERSONAS=$PERSONAS"
echo "# ENVIRONNEMENT=$ENVIRONNEMENT"
echo "# NODES=$NODES"
echo "# WALLET=$WALLET"
HERE=`pwd`
echo "# HERE=$HERE"

echo "# sourceForUser root root \"$ENVIRONNEMENT\""
sourceForUser root root "$ENVIRONNEMENT"
echo "# sourceForUser $USER root \"$ENVIRONNEMENT\""
sourceForUser "$USER" root "$ENVIRONNEMENT"

if [ -d "$PROJECT_DIR" ]; then
	echo "# echo \"$PROJECT_DIR exist\""
else
   echo "# mkdir $PROJECT_DIR"
   mkdir $PROJECT_DIR
   userRights $USER $PROJECT_DIR
fi   

echo "# echo \"Move to $PROJECT_DIR""
userGitClone $USER "$PROJECT_DIR" "$INSTALL_GIT" "ElementProject_install" "$INSTALL_DIR"
userRights $USER $INSTALL_DIR
echo "# rm -rf $HERE"
rm -rf $HERE

if [ "$APT" == "yes" ]
   then 
   		echo "# "
   		echo "# "
   		echo "# "
		echo "# **************"
		echo "# Apt install"
		echo "# The full install take around 2h"
		echo "# This part take around 10min"
		echo "# **************"
		suDoLog $INSTALL_DIR "apt-get install -y apt-utils" "apt_install"
		suDoLog $INSTALL_DIR "apt-get update -y" "apt_update" "apt_update"
		suDoLog $INSTALL_DIR "apt-get upgrade -y" "apt_upgrade" "apt_upgrade"
		suDoLog $INSTALL_DIR "apt-get install -y $APT_LIST" "apt_install"
		suDoLog $INSTALL_DIR "apt-get update -y --fix-missing" "apt_missing"
fi
if [ "$BERKELEY_DB" == "yes" ]
   then    		
   		echo "# "
   		echo "# "
   		echo "# "
		echo "# **************"
		echo "# Berkeley DB install"
		echo "# The full install take around 2h"
		echo "# This part take around 5min"
		echo "# **************"
		userMkdir $USER "$PROJECT_DIR"
		userGitClone $USER "$PROJECT_DIR" "$ELEMENTS_GIT" "elements_gitClone" "$PROJECT_ELEMENTS_DIR"
		suDoLog "$PROJECT_ELEMENTS_DIR" "$PROJECT_ELEMENTS_DIR/contrib/install_db4.sh $DB4_INSTALL_PATH" "db4_install"
fi
if [ "$BITCOIN" == "yes" ]
   then    		
   		echo "# "
   		echo "# "
   		echo "# "
		echo "# **************"
		echo "# Bitcoin install"
		echo "# The full install take around 2h"
		echo "# This part take around 40min"
		echo "# **************"		
		userGitClone $USER "$PROJECT_DIR" "$BITCOIN_SIMPLICITY_GIT" "bitcoin_install" "$PROJECT_BITCOIN_DIR"
		userGitChekout $USER "$PROJECT_BITCOIN_DIR" $PROJECT_BITCOIN_BRANCH
		userDoLog $USER "$PROJECT_BITCOIN_DIR" "$PROJECT_BITCOIN_DIR/./autogen.sh" "bitcoin_install"
		userDoLog $USER "$PROJECT_BITCOIN_DIR" "$BITCOIN_CONFIGURE" "bitcoin_install"
		suDoLog "$PROJECT_BITCOIN_DIR" make "bitcoin_install"
fi
if [ "$SIMPLICITY" == "yes" ]
   then   
   		echo "# "
   		echo "# "
   		echo "# "
		echo "# **************"
		echo "# Simplicity install"
		echo "# The full install take around 2h"
		echo "# This part take around 5min"
		echo "# **************"
		userGitClone $USER "$PROJECT_DIR" "$SIMPLICITY_GIT" "simplicity_install" "$PROJECT_SIMPLICITY_DIR"
		userGitChekout $USER "$PROJECT_SIMPLICITY_DIR" "$PROJECT_SIMPLICITY_BRANCH"
		userDoLog $USER "$PROJECT_DIR" "cabal update" "simplicity_install"		
		userDoLog $USER "$PROJECT_DIR" "cabal install bech32-1.0.2 unification-fd cereal lens-family-2.0.0 SHA MemoTrie" "simplicity_install"
		userDoLog $USER "$PROJECT_SIMPLICITY_DIR" "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs >> sh.rustup.rs"
		userDo $USER "$PROJECT_SIMPLICITY_DIR" "sh sh.rustup.rs -y"
		userDo $USER "$PROJECT_SIMPLICITY_DIR" "source /home/$USER/.cargo/env"
		userMkdir $USER "$PROJECT_HAL_DIR"		
		userWgetTarxzf $USER "$PROJECT_HAL_DIR" "$HAL_INSTALL_URL"
		userDoLog $USER "$PROJECT_HAL_DIR" "source /home/$USER/.cargo/env && cargo install hal" "simplicity_install"
fi
if [ "$NIX" == "yes" ]
   then
   		echo "# "
   		echo "# "
   		echo "# "
		echo "# **************"
		echo "# Nix install"
		echo "# The full install take around 2h"
		echo "# This part take around 5min"
		echo "# **************"
		userMkdir $USER "$PROJECT_NIX_DIR"		
		userDoLog $USER "$PROJECT_DIR" "curl $NIX_INSTALL_URL | sh"		
		userDo $USER "$PROJECT_DIR" ". /home/$PROJECT_USER/.nix-profile/etc/profile.d/nix.sh"		
		simplicityenv
		
fi
if [ "$ELEMENTS" == "yes" ]
   then
   		echo "# "
   		echo "# "
   		echo "# "
		echo "# **************"
		echo "# Elements install"
		echo "# This part take around 40min"
		echo "# **************"	
		userGitChekout $USER "$PROJECT_ELEMENTS_DIR" $PROJECT_ELEMENTS_BRANCH			
		userDo $USER "$PROJECT_ELEMENTS_DIR" "$PROJECT_ELEMENTS_DIR/./autogen.sh"		
		userDoLog $USER "$PROJECT_ELEMENTS_DIR" "$ELEMENTS_CONFIGURE" "elements_install"
		suDoLog "$PROJECT_ELEMENTS_DIR" "make" "elements_install"
		suDoLog "$PROJECT_ELEMENTS_DIR" "make install" "elements_install"
fi
if [ "$PERSONAS" == "yes" ]
   then
   		echo "# "
   		echo "# "
   		echo "# "
		echo "# **************"
		echo "# Personas install"
		echo "# The full install take around 2h"
		echo "# This part take around 1min"
		echo "# **************"		
		userMkdir $USER "$USER_BITCOIN_DIR" BC="regtest=$PROJECT_BITCOIN_REGTEST\ndaemon=$PROJECT_BITCOIN_DAEMON\ntxindex=$PROJECT_BITCOIN_TXINDEX\nregtest.rpcport=$PROJECT_BITCOIN_REGTEST_RPC_PORT\nregtest.port=$PROJECT_BITCOIN_REGTEST_PORT\nrpcuser=$PROJECT_BITCOIN_REGTEST_RPC_USER\nrpcpassword=password$PROJECT_BITCOIN_REGTEST_RPC_PASSWORD\n"
		suDoLog "$PROJECT_DIR" "echo -e $BC >> $USER_BITCOIN_CONF" "PersonasInstall"
	        suDoLog "$PROJECT_DIR" "chmod 0755 $USER_BITCOIN_CONF && chown $USER $USER_BITCOIN_CONF" "PersonasInstall"
        	suDoLog "$PROJECT_DIR" "echo cat $USER_BITCOIN_CONF" "PersonasInstall"
		suDoLog "$PROJECT_DIR" "btcd" "PersonasInstall"
		echo "# personaCreate $PROJECT_ELEMENTS_REGTEST_RPC_USER_ALICE $PROJECT_ELEMENTS_REGTEST_RPC_PASSWORD_ALICE $PROJECT_ELEMENTS_REGTEST_RPC_PORT_ALICE $PROJECT_ELEMENTS_REGTEST_PORT_ALICE $PROJECT_ELEMENTS_REGTEST_PORT_LOCAL_ALICE $PROJECT_ELEMENTS_INITIAL_FREE_COINS_ALICE $USER_ALICE_NAME"
		personaCreate $PROJECT_ELEMENTS_REGTEST_RPC_USER_ALICE $PROJECT_ELEMENTS_REGTEST_RPC_PASSWORD_ALICE $PROJECT_ELEMENTS_REGTEST_RPC_PORT_ALICE $PROJECT_ELEMENTS_REGTEST_PORT_ALICE $PROJECT_ELEMENTS_REGTEST_PORT_LOCAL_ALICE $PROJECT_ELEMENTS_INITIAL_FREE_COINS_ALICE $USER_ALICE_NAME
		echo "# personaCreate $PROJECT_ELEMENTS_REGTEST_RPC_USER_BOB $PROJECT_ELEMENTS_REGTEST_RPC_PASSWORD_BOB $PROJECT_ELEMENTS_REGTEST_RPC_PORT_BOB $PROJECT_ELEMENTS_REGTEST_PORT_BOB $PROJECT_ELEMENTS_REGTEST_PORT_LOCAL_BOB $PROJECT_ELEMENTS_INITIAL_FREE_COINS_BOB $USER_BOB_NAME"	
		personaCreate $PROJECT_ELEMENTS_REGTEST_RPC_USER_BOB $PROJECT_ELEMENTS_REGTEST_RPC_PASSWORD_BOB $PROJECT_ELEMENTS_REGTEST_RPC_PORT_BOB $PROJECT_ELEMENTS_REGTEST_PORT_BOB $PROJECT_ELEMENTS_REGTEST_PORT_LOCAL_BOB $PROJECT_ELEMENTS_INITIAL_FREE_COINS_BOB $USER_BOB_NAME
		echo "# personaAddressAdd \"ALICE\" \"MINER\""
		personaAddressAdd "ALICE" "MINER"
		suDoLog "$PROJECT_DIR" "chmodx \"$INSTALL_DIR/../elementsProjectStart.sh\"" "PersonasInstall"
		suDoLog "$PROJECT_DIR" "chmodx \"$INSTALL_DIR/../elementsProjectStop.sh\"" "PersonasInstall"
		suDoLog "$PROJECT_DIR" "chmodx \"$INSTALL_DIR/../test/test_transaction_simple.sh\"" "PersonasInstall"
fi
if [ "$NODE" == "yes" ]	
   then   
	echo "# "
	echo "# "
	echo "# "
	echo "# **************"
	echo "# Node install"
	echo "# This part take around 2min"
	echo "# **************"
    suDoLog "$PROJECT_DIR" "curl -sL $NODE_INSTALL_URL | bash -" "nodeInstall"
    suDoLog "$PROJECT_DIR" "apt-get install -y nodejs" "nodeInstall"
    suDoLog "$PROJECT_DIR" "npm install -g npm@latest" "nodeInstall"
fi
if [ "$WALLET" == "yes" ]
   then   
	echo "# "
	echo "# "
	echo "# "
	echo "# **************"
	echo "# Bcoin install"
	echo "# This part take around 2min"
	echo "# **************"
    	userGitClone $USER "$PROJECT_DIR" "$BCOIN_GIT" "bcoinInstall" "$BCOIN_DIR"
	suDoLog "$BCOIN_DIR" "npm rebuild" "bcoinInstall"
    	suDoLog "$BCOIN_DIR" "npm install --global" "bcoinInstall"
	# bcoin --http-host=0.0.0.0 --api-key $USER --daemon
fi
exit
echo "# "
echo "# "
echo "# "
suDo "$INSTALL_DIR" "cat ../../conf/elementsProject.conf >> $INSTALL_LOG_DIR/result.log" "resultInstall"
suDo "$INSTALL_DIR" "cat /home/$USER/.elementsProject_$USER_$USER.conf >> $INSTALL_LOG_DIR/result.log" "resultInstall"
suDo "$INSTALL_DIR" "cat USER_BITCOIN_CONF >> $INSTALL_LOG_DIR/result.log" "resultInstall"
suDo "$INSTALL_DIR" "cat /home/$PROJECT_USER/ALICEData/elements.conf >> $INSTALL_LOG_DIR/result.log" "resultInstall"
suDo "$INSTALL_DIR" "cat /home/$PROJECT_USER/BOBData/elements.conf >> $INSTALL_LOG_DIR/result.log" "resultInstall"
suDo "$INSTALL_LOG_DIR" "echo "ls $INSTALL_LOG_DIR -al >> $INSTALL_DIR/result.log"
