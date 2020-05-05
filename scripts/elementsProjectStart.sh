#!/bin/bash

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

source install/functions.sh
cd install
source ../../conf/elementsProject.conf $USER $USER

btcd
aliced
bobd
