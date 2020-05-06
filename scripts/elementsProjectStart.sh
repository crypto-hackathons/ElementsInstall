#!/bin/bash

USER=$USER
ENVIRONNEMENT="regtest"

while getopts u:v: option
	do
		case "${option}"
		in
			u) USER=${OPTARG};;
			v) ENVIRONNEMENT=${OPTARG};;
		esac
	done

if [ $USER == "root" ]
   then
   		echo "USER must not be root"
   		exit
fi
echo "USER=$USER"
echo "ENVIRONNEMENT=$ENVIRONNEMENT"
echo "$ source install/functions.sh" 
source install/functions.sh
echo "cd install"
cd install
echo "$ source \"/home/$USER/.elementsProject_$USER_$ENVIRONNEMENT.conf\" $USER $USER $ENVIRONNEMENT"
source "/home/$USER/.elementsProject_$USER_$ENVIRONNEMENT.conf" $USER $USER $ENVIRONNEMENT

echo "nohup $PROJECT_BITCOIN_DIR/src/./bitcoind -datadir=$USER_BITCOIN_DIR &>/dev/null &"
btcd
echo "nohup $PROJECT_ELEMENTS_DIR/src/./elementsd -datadir=$USER_ALICE_DIR &>/dev/null &"
aliced
echo "nohup $PROJECT_ELEMENTS_DIR/src/./elementsd -datadir=$USER_BOB_DIR &>/dev/null &"
bobd
