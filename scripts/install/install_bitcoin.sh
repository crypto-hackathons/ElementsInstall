#!/bin/bash

echo "**************"
echo "Configure"
echo "**************"
source ../../conf/elementsProject.conf $1

echo "**************"
echo "Bitcoin"
echo "**************"
allCd $1 "$PROJECT_DIR"
userGitClone $1 "https://github.com/roconnor-blockstream/bitcoin.git" "bitcoin_gitClone" "$PROJECT_BITCOIN_DIR"
allCd $1 "$PROJECT_BITCOIN_DIR"
userGitChekout $1 "simplicity"
userDoLog $1 "./autogen.sh" "bitcoin_autogen"
userDoLog $1 "./configure BDB_LIBS=\"-L${BDB_PREFIX}/lib -ldb_cxx-4.8\" BDB_CFLAGS=\"-I${BDB_PREFIX}/include\" --disable-dependency-tracking --with-gui=no --disable-test --disable-bench" "bitcoin_configure"
suDo "make" "bitcoin_make"
allCd $1 "$PROJECT_BITCOIN_DIR"
suDo "btcd -daemon"
exit
