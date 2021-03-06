#!/bin/bash

function userRights()
{
    echo "# chmod 0755 $2 && chown $2"
    chmod 0755 $2 && chown $1 $2
}
function sourceForUser()
{	
   LIB_DIR="../../lib"
   CONF_DIR="../../conf"
   PROJECT_CONF="$CONF_DIR/elementsProject.conf"
   export USER_CONF="/home/$1/.elementsProject_$2_$3.conf"	

   if [ -f "$USER_CONF" ]
   then   
	    echo "# rm $USER_CONF"
	    rm  $USER_CONF
    fi
    echo "# source $PROJECT_CONF $1 root $3 $LIB_DIR >> $USER_CONF"
    source $PROJECT_CONF $1 root $3 $LIB_DIR >> $USER_CONF	
    userRights $USER $USER_CONF
    echo "# chmod +x $USER_CONF" 
    chmod +x $USER_CONF
}
function echoPart(){

	echo "echo \"**************\""
	echo "echo $1"
	echo "echo \"**************\""
}
function exportAll()
{
	echo "export $1=\"$2\""
	export $1="$2"
}
function aliasAll()
{
	shopt -s expand_aliases
	CMD=$2
  	CMD2="${CMD//[\"]/\\\"}"
    
	echo "alias $1=\"$CMD2\""
	alias $1="$CMD2"
}
function userMkdir()
{
   if [ -d "$2" ]
   then
	    echo "# rm -rf $2"
	    rm -rf $2
  fi
  echo "# mkdir $2"
  mkdir $2
  userRights $1 $2
}
function userCd()
{
  echo "$ cd $2"
  su $1 -c "cd $2"
}
function userDo()
{
  echo "$ cd $2 && $3"
  su $1 -c "cd $2 && $3"
}
function suCd()
{
  echo "# cd $1"
  cd $1
}
function suDo(){

  suCd $1

  echo "# $2"
  $2
}
function userDoLog()
{
  echo "$ cd $2 && $3 >> $INSTALL_LOG_DIR/$4.log"
  su $1 -c "cd $2 && $3" >> $INSTALL_LOG_DIR/$4.log
}
function suDoLog()
{
  suCd $1
  
  echo "# $2 >> $INSTALL_LOG_DIR/$3.log"
  $2 >> $INSTALL_LOG_DIR/$3.log
}
function userCongigure()
{  
  CMD="$3"
  CMD3="${CMD//[\"]/\\\"}"
     
  echo "$ cd $2 && ./configure $3"
  su $1 -c "cd $2 && ./configure $CMD"
}
function userGitClone()
{
   if [ -d "$5" ]; then
        echo "# echo \"$5 exist\""
	    echo "# rm -rf $5"
	    rm -rf $5
	 else
	 	echo "# echo \"$5 not exist\""
  fi
  echo "$ cd $2 && git clone $3 >> $INSTALL_LOG_DIR/$4.log"
  su $1 -c "cd $2 && git clone $3 >> $INSTALL_LOG_DIR/$4.log"
}
function userGitChekout()
{
   echo "$ cd $2 && git checkout $3"
   su $1 -c "cd $2 && git checkout $3"
}
function userWgetTarxzf(){

	echo "$ cd $2 && wget $3 && tar xzf $3"
	BASENAME=basename $3
	su $1 -c "cd $2 && wget $3"
	echo "$ FN=$3"
	FN=$3
	echo "$ BN=\"${FN##*/}\""
	BN="${FN##*/}"
	echo "$ $BN"
	echo "cd $2 && tar xzf $BN"	
	su $1 -c "cd $2 && tar xzf $BN"
}
function chmodx()
{
	echo "# chmod +x $1"
	chmod +x $1	
}
function simplicityenv()
{
	echo "# nix-shell -p \"(import ./default.nix {}).haskellPackages.ghcWithPackages (pkgs: with pkgs; [Simplicity bech32])\""
	nix-shell -p "(import ./default.nix {}).haskellPackages.ghcWithPackages (pkgs: with pkgs; [Simplicity bech32])"
}
function btcd()
{
	echo "# nohup $PROJECT_BITCOIN_DIR/src/./bitcoind -regtest -datadir=$USER_BITCOIN_DIR &>/dev/null &"
	nohup $PROJECT_BITCOIN_DIR/src/./bitcoind -regtest -datadir=$USER_BITCOIN_DIR &>/dev/null &
}
function btc-cli()
{
	echo "# $PROJECT_BITCOIN_DIR/src/./bitcoin-cli -datadir=$USER_BITCOIN_DIR"
	$PROJECT_BITCOIN_DIR/src/./bitcoin-cli -datadir=$USER_BITCOIN_DIR
}
function aliced()
{	
	echo "# nohup $PROJECT_ELEMENTS_DIR/src/./elementsd -regtest -datadir=$USER_ALICE_DIR &>/dev/null &"
	nohup $PROJECT_ELEMENTS_DIR/src/./elementsd -regtest -datadir=$USER_ALICE_DIR &>/dev/null &
}
function bobd()
{
	echo "# nohup $PROJECT_ELEMENTS_DIR/src/./elementsd -regtest -datadir=$USER_BOB_DIR &>/dev/null &"
	nohup $PROJECT_ELEMENTS_DIR/src/./elementsd -regtest -datadir=$USER_BOB_DIR &>/dev/null &
}
function alice-cli()
{
	echo "# $PROJECT_ELEMENTS_DIR/src/./elements-cli -datadir=$USER_ALICE_DIR"
	$PROJECT_ELEMENTS_DIR/src/./elements-cli -datadir=$USER_ALICE_DIR
}
function bob-cli()
{
	echo "# $PROJECT_ELEMENTS_DIR/src/./elements-cli -datadir=$USER_BOB_DIR"
	$PROJECT_ELEMENTS_DIR/src/./elements-cli -datadir=$USER_BOB_DIR
}
function aliceGetNewAddress()
{
	echo "# alice-cli getnewaddress"
	alice-cli getnewaddress
}
function bobGetNewAddress()
{
	echo "# bob-cli getnewaddress"
	bob-cli getnewaddress
}
function personaCreate()
{
	CHAIN="elementsregtest"
	if [ "$PROJECT_ENVIRONNEMENT" != "regtest" ]
	   then
	   CHAIN="elementsmain" 
	fi	
	echo "# CHAIN=$CHAIN"
	echo "# USER_DIR=\"/home/$PROJECT_USER/$7Data\""
	USER_DIR="/home/$PROJECT_USER/$7Data"
	echo "# USER_CONF=$USER_DIR/elements.conf"
	USER_CONF=$USER_DIR/elements.conf
	if [ -f "$USER_CONF" ]
   then   
	    echo "# rm $USER_CONF"
	    rm  $USER_CONF
    fi
	userMkdir $USER "$USER_DIR"
	EC="chain=$CHAIN\nrpcuser=$1\nrpcpassword=$2\nelementsregtest.rpcport=$3\nelementsregtest.port=$4\nelementsregtest.connect=localhost:$5\nrpcport=$3\ndaemon=1\nlisten=1\ntxindex=1\nvalidatepegin=1\nmainchainrpcport=$PROJECT_BITCOIN_REGTEST_RPC_PORT\nmainchainrpcuser=$PROJECT_BITCOIN_REGTEST_RPC_USER\nmainchainrpcpassword=$PROJECT_BITCOIN_REGTEST_RPC_PASSWORD\ninitialfreecoins=$6\n"

	echo "# echo -e $BC >> $USER_CONF"
	echo -e $EC >> $USER_CONF
	
	echo "# chmod 0755 $USER_CONF && chown $USER $USER_CONF"
	chmod 0755 $USER_CONF && chown $USER $USER_CONF
	echo "**************"
	echo "Configration $7"
	echo "**************"
	echo "# echo cat $USER_CONF" 
	echo cat $USER_CONF
	
	echo "# nohup $PROJECT_ELEMENTS_DIR/src/./elementsd -datadir=$USER_DIR &>/dev/null &"
	nohup $PROJECT_ELEMENTS_DIR/src/./elementsd -datadir=$USER_DIR &>/dev/null &
	
	echo "# USER_ADDRESS=$($PROJECT_ELEMENTS_DIR/src/./elements-cli -datadir=$USER_DIR getnewaddress)"
	USER_ADDRESS=$($PROJECT_ELEMENTS_DIR/src/./elements-cli -datadir=$USER_DIR getnewaddress)
	echo "# echo USER_NAME=$7 >> $USER_CONF"
	echo "USER_NAME=$7" >> $USER_CONF
	echo "# echo USER_ADDRESS=$USER_ADDRESS >> $USER_CONF"	
	echo "USER_ADDRESS=$USER_ADDRESS" >> $USER_CONF
	echo "# echo USER_CONF=$USER_CONF >> $USER_CONF"	
	echo "USER_CONF=$USER_CONF" >> $USER_CONF
}
function personaAddressAdd()
{
	echo "**************"
	echo "Configration of $1_$2"
	echo "**************"
	# $1 user
	# $2 address_suffix
	echo "# USER_DIR=\"/home/$PROJECT_USER/$1Data\""
	USER_DIR="/home/$PROJECT_USER/$1Data"
	echo "# USER_CONF=$USER_DIR/elements.conf"
	USER_CONF=$USER_DIR/elements.conf
	echo "# USER_ADDRESS=$($PROJECT_ELEMENTS_DIR/src/./elements-cli -datadir=$USER_DIR getnewaddress)"
	USER_ADDRESS=$($PROJECT_ELEMENTS_DIR/src/./elements-cli -datadir=$USER_DIR getnewaddress)
	echo "# echo USER_NAME_$2=$1_$2 >> $USER_CONF"
	echo "USER_NAME_$2=$1_$2" >> $USER_CONF
	echo "# echo USER_ADDRESS_$2=$USER_ADDRESS >> $USER_CONF"	
	echo "USER_ADDRESS_$2=$USER_ADDRESS" >> $USER_CONF
}
