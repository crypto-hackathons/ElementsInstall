#!/bin/bash

shopt -s expand_aliases

function sourceForUser()
{	
	PROJECT_CONF="../../conf/elementsProject.conf"
	export USER_CONF="/home/$1/.elementsProject_$2_$3.conf"	

	if [ -f "$USER_CONF" ]
   then   
	    echo "# rm $USER_CONF"
	    rm  $USER_CONF
    fi
    echo "# source $PROJECT_CONF $1 root $3 >> $USER_CONF"
	source $PROJECT_CONF $1 root $3 >> $USER_CONF
	
	echo "# chmod 0755 $USER_CONF && chown $USER $USER_CONF"
	chmod 0755 $USER_CONF && chown $USER $USER_CONF
	echo "# chmod +x $USER_CONF" 
	chmod +x $USER_CONF
}
echoPart(){

	echo "echo \"**************\""
	echo "echo $1"
	echo "echo \"**************\""
}
exportAll()
{
	echo "export $1=\"$2\""
	export $1="$2"
}
aliasAll()
{
	CMD=$2
  	CMD2="${CMD//[\"]/\\\"}"
    
	echo "alias $1=\"$CMD2\""
	alias $1="$CMD2"
}
userMkdir()
{
   if [ -d "$2" ]
   then
	    echo "# rm -rf $2"
	    rm -rf $2
  fi
  echo "# mkdir $2"
  mkdir $2
  echo "# chmod 0755 $2 && chown $1 $2"
  chmod 0755 $2 && chown $1 $2
}
userCd()
{
  echo "$ cd $2"
  su $1 -c "cd $2"
}
userDo()
{
  echo "$ cd $2 && $3"
  su $1 -c "cd $2 && $3"
}
suCd()
{
  echo "# cd $1"
  cd $1
}
suDo(){

  suCd $1

  echo "# $2"
  $2
}
userDoLog()
{
  echo "$ cd $2 && $3 >> $INSTALL_LOG_DIR/$4.log"
  su $1 -c "cd $2 && $3" >> $INSTALL_LOG_DIR/$4.log
}
suDoLog()
{
  suCd $1
  
  echo "# $2 >> $INSTALL_LOG_DIR/$3.log"
  $2 >> $INSTALL_LOG_DIR/$3.log
}
userCongigure()
{  
  CMD="$3"
  CMD3="${CMD//[\"]/\\\"}"
     
  echo "$ cd $2 && ./configure $3"
  su $1 -c "cd $2 && ./configure $CMD"
}
userGitClone()
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
userGitChekout()
{
   echo "$ cd $2 && git checkout $3"
   su $1 -c "cd $2 && git checkout $3"
}
userWgetTarxzf(){

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
chmodx()
{
	echo "# chmod +x $1"
	chmod +x $1	
}
function simplicityenv()
{
	nix-shell -p "(import ./default.nix {}).haskellPackages.ghcWithPackages (pkgs: with pkgs; [Simplicity bech32])"
}
function btcd()
{
	nohup $PROJECT_BITCOIN_DIR/src/./bitcoind -regtest -datadir=$USER_BITCOIN_DIR &>/dev/null &
}
function btc-cli()
{
	$PROJECT_BITCOIN_DIR/src/./bitcoin-cli -datadir=$USER_BITCOIN_DIR
}
function aliced()
{	
	nohup $PROJECT_ELEMENTS_DIR/src/./elementsd -regtest -datadir=$USER_ALICE_DIR &>/dev/null &
}
function bobd()
{
	nohup $PROJECT_ELEMENTS_DIR/src/./elementsd -regtest -datadir=$USER_BOB_DIR &>/dev/null &
}
function alice-cli()
{
	$PROJECT_ELEMENTS_DIR/src/./elements-cli -datadir=$USER_ALICE_DIR
}
function bob-cli()
{
	$PROJECT_ELEMENTS_DIR/src/./elements-cli -datadir=$USER_BOB_DIR
}
function aliceGetNewAddress()
{
	alice-cli getnewaddress
}
function bobGetNewAddress()
{
	bob-cli getnewaddress
}
function personaCreate()
{
	CHAIN="elementsregtest"
	if [ "$PROJECT_ENVIRONNEMENT" != "regtest" ]
	   then
	   CHAIN="elementsmain" 
	fi	
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
	EC="chain=$CHAIN 
rpcuser=$1
rpcpassword=$2
elementsregtest.rpcport=$3
elementsregtest.port=$4
elementsregtest.connect=localhost:$5
rpcport=$3
daemon=1
listen=1
txindex=1
validatepegin=1
mainchainrpcport=$PROJECT_BITCOIN_REGTEST_RPC_PORT
mainchainrpcuser=$PROJECT_BITCOIN_REGTEST_RPC_USER
mainchainrpcpassword=$PROJECT_BITCOIN_REGTEST_RPC_PASSWORD
initialfreecoins=$6"

	echo "# echo $BC >> $USER_CONF"
	echo EC >> $USER_CONF
	
	echo "# chmod 0755 $USER_CONF && chown $USER $USER_CONF"
	chmod 0755 $USER_CONF && chown $USER $USER_CONF
	echo "**************"
	echo "Configration $7"
	echo "**************" 
	echo cat $USER_CONF
	
	echo "nohup $PROJECT_ELEMENTS_DIR/src/./elementsd -datadir=$USER_DIR &>/dev/null &"
	nohup $PROJECT_ELEMENTS_DIR/src/./elementsd -datadir=$USER_DIR &>/dev/null &
	
	echo "USER_ADDRESS=$PROJECT_ELEMENTS_DIR/src/./elements-cli -datadir=$USER_DIR getnewaddress"
	USER_ADDRESS=$PROJECT_ELEMENTS_DIR/src/./elements-cli -datadir=$USER_DIR getnewaddress
	echo $USER_ADDRESS
	echo "USER_NAME=$7" >> $USER_CONF	
	echo "USER_ADDRESS=$USER_ADDRESS" >> $USER_CONF	
	echo "USER_CONF=$USER_CONF" >> $USER_CONF
}


