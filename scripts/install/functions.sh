#!/bin/bash

shopt -s expand_aliases

function sourceForUser()
{	
	if [ -f "../../conf/elementsProject_$1_$2.conf" ]
   then
	    echo "# rm ../../conf/elementsProject_$1_$2.conf"
	    rm -y "../../conf/elementsProject_$1_$2.conf"
    fi
	source ../../conf/elementsProject.conf $1 "root" >> "../../conf/elementsProject_$1_$2.conf"
	echo "# cat ../../conf/elementsProject_$1_$2.conf"
	cat "../../conf/elementsProject_$1_$2.conf"
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
chmodx(){
	echo "# chmod +x $1"
	chmod +x $1	
}
function simplicityenv()
{
	echo "nix-shell -p \"(import ./default.nix {}).haskellPackages.ghcWithPackages (pkgs: with pkgs; [Simplicity bech32])\""
	nix-shell -p "(import ./default.nix {}).haskellPackages.ghcWithPackages (pkgs: with pkgs; [Simplicity bech32])"
}
function btcd(){

	echo "nohup $PROJECT_BITCOIN_DIR/src/./bitcoind -regtest -datadir=$USER_BITCOIN_DIR &>/dev/null &"
	nohup $PROJECT_BITCOIN_DIR/src/./bitcoind -regtest -datadir=$USER_BITCOIN_DIR &>/dev/null &
}
function btc-cli()
{
	$PROJECT_BITCOIN_DIR/src/./bitcoin-cli -regtest -datadir=$USER_BITCOIN_DIR
}
function aliced()
{
	echo "nohup $PROJECT_ELEMENTS_DIR/src/./elementsd -regtest -datadir=$USER_ALICE_DIR &>/dev/null &"	
	nohup $PROJECT_ELEMENTS_DIR/src/./elementsd -regtest -datadir=$USER_ALICE_DIR &>/dev/null &
}
function bobd()
{
	nohup $PROJECT_ELEMENTS_DIR/src/./elementsd -regtest -datadir=$USER_BOB_DIR &>/dev/null &
}
function alice-cli()
{
	$PROJECT_ELEMENTS_DIR/src/./elements-cli -regtest -datadir=$USER_ALICE_DIR
}
function bob-cli()
{
	$PROJECT_ELEMENTS_DIR/src/./elements-cli -regtest -datadir=$USER_BOB_DIR
}
function aliceGetNewAddress()
{
	alice-cli getnewaddress
}
function bobGetNewAddress()
{
	bob-cli getnewaddress
}
