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
  echo "# $1"
  cd $1
}
suDo(){

  suCd $2

  echo "# $1"
  $1
}
userDoLog()
{
  echo "$ cd $2 && $3 >> $INSTALL_LOG_DIR/$4.log"
  su $1 -c "cd $2 && $3" >> $INSTALL_LOG_DIR/$4.log
}
suDoLog()
{
  suCd $2
  
  echo "# $1 >> $INSTALL_LOG_DIR/$3.log"
  $1 >> $INSTALL_LOG_DIR/$3.log
}
userCongigure()
{
	
  # userCd $1 $2
  
  CMD="$3"
  CMD3="${CMD//[\"]/\\\"}"
     
  echo "$ cd $2 && ./configure $3"
  su $1 -c "cd $2 && ./configure $CMD"
}
userGitClone()
{
   # userCd $1 $2

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
   # userCd $1 $2

   echo "$ cd $2 && git checkout $3"
   su $1 -c "cd $2 && git checkout $3"
}
userWgetTarxzf(){

	echo "$ cd $2 && wget $3 && tar xzf $3"
	BASENAME=basename $3
	su $1 -c "cd $2 && wget $3"
	echo "FN=$3"
	FN=$3
	echo "BN=\"${FN##*/}\""
	BN="${FN##*/}"
	echo "$BN"
	echo "cd $2 && tar xzf $BN"	
	su $1 -c "cd $2 && tar xzf $BN"
}
chmodx(){
	echo "# chmod +x $1"
	chmod +x $1	
}
function btcd(){

	$PROJECT_BITCOIN_DIR/src/./bitcoind -regtest -datadir=$USER_BITCOIN_DIR
}
