#!/bin/bash
shopt -s expand_aliases

function sourceForUser()
{	
	if [ -f "$2" ]
   then
	    echo "# rm ../../conf/elementsProject_$1_$2.conf"
	    rm "../../conf/elementsProject_$1_$2.conf"
    fi
	source ../../conf/elementsProject.conf $1 "root" >> "../../conf/elementsProject_$1_$2.conf"
	echo "# cat ../../conf/elementsProject_$1_$2.conf"
	cat "../../conf/elementsProject_$1_$2.conf"
}
echoPart(){

	echo "echo \"**************\""
	echo "echo \"$1\""
	echo "echo \"**************\""
}
exportAll()
{
	echo "export $3=\"$4\""
	export $3="$4"
}
aliasAll()
{
	CMD=$4
  	CMD4="${CMD//[\"]/\\\"}"
    
	echo "alias $3=\"$CMD4\""
	alias $3="$CMD4"
}
userDo()
{
  echo "$ $2"
  su $1 -c "$2"
}
suDo(){

  echo "# $1"
  $1
}
userDoLog()
{

  echo "$ $2 >> $INSTALL_LOG_DIR/$3.log"
  su $1 -c "$2" >> $INSTALL_LOG_DIR/$3.log
}
suDoLog()
{
  echo "# $1 >> $INSTALL_LOG_DIR/$2.log"
  $1 >> $INSTALL_LOG_DIR/$2.log
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
allCd(){

	userDo $1 "cd $2"

	echo "# cd $2"
	cd $2	
}
userCongigure()
{  
  CMD="$2"
  CMD2="${CMD//[\"]/\\\"}"
     
  echo "$ ./configure $2"
  su $1 -c "./configure $CMD"
}
userGitClone()
{
   # su $1 -c "echo `pwd`"
   if [ -d "$4" ]
   then
	    echo "# rm -rf $4"
	    rm -rf $4
  fi
  echo "$ git clone $2 >> $INSTALL_LOG_DIR/$3.log"
  su $1 -c "git clone $2 >> $INSTALL_LOG_DIR/$3.log"
}
userGitChekout()
{
   echo "$ git checkout $2"   
   su $1 -c "git checkout $2"
}
userWgetTarxzf(){
	userDo $1 "wget $1"
	userDo $1 "tar xzf $2"
}
chmodx(){
	echo "# chmod +x $1"
	chmod +x $1	
}
function btcd(){

	$PROJECT_BITCOIN_DIR/src/./bitcoind -regtest -datadir=$USER_BITCOIN_DIR
}
