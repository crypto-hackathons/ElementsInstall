#!/bin/bash

./elementsProjectStart.sh $1

echo "Alice wallet"
alice-cli getwalletinfo

echo "Bob wallet"
bob-cli getwalletinfo

echo "Send 21000000 BTC to the ALICE_RECEIVER_ADDRESS address"
alice-cli sendtoaddress $ALICE_RECEIVER_ADDRESS 21000000 "" "" true
alice-cli generatetoaddress 102 $ALICE_MINER_ADDRESS

echo "Alice transactions list"
alice-cli listtransactions

echo "Send 10,5 millions of BTC from node 1 (ALICE_RECEIVER_ADDRESS) to node 2 (BOB_RECEIVER_ADDRESS)"
alice-cli sendtoaddress $BOB_RECEIVER_ADDRESS 10500000 "" "" false
alice-cli generatetoaddress 102 $ALICE_MINER_ADDRESS


echo "Alice balance"
alice-cli getbalance

echo "Bob balance"
bob-cli getbalance

echo "Get addresses of Alice wallet"
alice-cli listaddressgroupings

echo "Select txcount from getwalletinfo JSON result"
alice-cli getwalletinfo | jq '.txcount'