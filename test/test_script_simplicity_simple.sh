#!/bin/bash

export PROJECT_USER=$1

source elementsProject



./elementsProjectStart.sh $1



echo "Create a Bitcoin address"

ADDRESS=$(btc getnewaddress)

btc generatetoaddress 102 $ADDRESS



simplicityenv

ghci -package Simplicity



let asProgram = id :: a () () -> a () ()

let makeBinaryProgram = Simplicity.Bitcoin.Jets.putTermLengthCode . asProgram



let order = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141

let priv = order `div` 2

let pubkey = Simplicity.LibSecp256k1.Schnorr.XOnlyPubKey 0x00000000000000000000003b78ce563f89a0ed9414f5aa28ad0d96d6795f9c63



-- Signature to verify with pubKey

let dummysig = Simplicity.LibSecp256k1.Schnorr.Sig 0 0



-- Create the binary of the simplicity program pkwCheckSigHashAll applied to pubkey and dummysig

let binaryDummySig = makeBinaryProgram $ Simplicity.Bitcoin.Programs.CheckSigHashAll.Lib.pkwCheckSigHashAll pubkey dummysig



let parseBinaryProgram bp = let Right x = Simplicity.Serialization.evalStreamWithError Simplicity.Bitcoin.Jets.getTermLengthCode bp in asProgram x



binaryDummySig



let showHash = flip Numeric.showHex "" . Simplicity.Digest.integerHash256



showHash cmr



:m + Data.Text



let Right hrp = Codec.Binary.Bech32.humanReadablePartFromText . Data.String.fromString $ "bcrt"

let simplictySegwitVersion = (-1) `mod` 32



let Right address = Codec.Binary.Bech32.encode hrp (Codec.Binary.Bech32.dataPartFromWords [toEnum simplictySegwitVersion] <> (Codec.Binary.Bech32.dataPartFromBytes . Data.Serialize.encode $ cmr))



address 



TXID=$(btc sendtoaddress "bcrt1lfvl3m3f0zea3s4smzapjm07258mxt8g7guut4rmmuqzzy60l7c4qfucdch" 1.0001 "" "" false)



PSBT=$(btc createpsbt "[{\"txid\": \"$TXID\", \"vout\": 1, \"sequence\": 4293967294}]" "[{\"$ADDRESS\": \"1.0\"}]")



PSBT=$(btc utxoupdatepsbt $PSBT)



btc decodepsbt $PSBT | jq



btc decodepsbt $PSBT | jq ".tx.vin[0].txid" | tr -d '"'



btc decodepsbt $PSBT | jq ".tx.vout[0].scriptPubKey.hex" | tr -d '"'



fg



:m - Data.Text



# Replace inputTxid by yours.

let inputTxid = "386105c4a514fc6808f4d607734df2249300730c520e60b4e42636b6a33d03ca"

let inputVout = 1

let inputValue = 100010000

let inputSequence = 4293967294



# replace my outputScript hex value 

let outputScript = "a91421bb834e651666a16cb414879fb08f8d9e21a12f87"

let outputValue = 100000000





let groupBy2 = Data.List.unfoldr (\l -> if null l then Nothing else Just (splitAt 2 l))

let readHex = fst . head . Numeric.readHex

let readTxid = readHex . concat . reverse . groupBy2

let parseScript = Data.ByteString.Lazy.pack . fmap readHex . groupBy2

let sighHashAllPrefix = Data.Digest.Pure.SHA.padSHA1 . Data.ByteString.Lazy.fromStrict $ Data.ByteString.Char8.pack "Simplicity\USSignature\GS" <> Data.Serialize.encode Simplicity.Bitcoin.Programs.CheckSigHashAll.Lib.sigAllCMR



let mkSigHashAll tx ix = Simplicity.Digest.bslHash . Data.Serialize.runPutLazy $ do { Data.Serialize.putLazyByteString sighHashAllPrefix; Data.Serialize.put (Simplicity.Bitcoin.DataTypes.sigTxInputsHash tx); Data.Serialize.put (Simplicity.Bitcoin.DataTypes.sigTxOutputsHash tx); Data.Serialize.putWord64be (Simplicity.Bitcoin.DataTypes.sigTxiValue (Simplicity.Bitcoin.DataTypes.sigTxIn tx Data.Array.! ix)); Data.Serialize.putWord32be ix; Data.Serialize.putWord32be (Simplicity.Bitcoin.DataTypes.sigTxLock tx); Data.Serialize.putWord32be (Simplicity.Bitcoin.DataTypes.sigTxVersion tx) }



let inputs = Data.Array.listArray (0, 0) [Simplicity.Bitcoin.DataTypes.SigTxInput { Simplicity.Bitcoin.DataTypes.sigTxiPreviousOutpoint = Simplicity.Bitcoin.DataTypes.Outpoint (Lens.Family2.review (Lens.Family2.over Simplicity.Digest.be256) (readTxid inputTxid)) inputVout, Simplicity.Bitcoin.DataTypes.sigTxiValue = inputValue, Simplicity.Bitcoin.DataTypes.sigTxiSequence = inputSequence }]



let outputs = Data.Array.listArray (0,0) [Simplicity.Bitcoin.DataTypes.TxOutput {Simplicity.Bitcoin.DataTypes.txoValue = outputValue, Simplicity.Bitcoin.DataTypes.txoScript = parseScript outputScript }]



let tx = Simplicity.Bitcoin.DataTypes.SigTx { Simplicity.Bitcoin.DataTypes.sigTxVersion = 2, Simplicity.Bitcoin.DataTypes.sigTxIn = inputs, Simplicity.Bitcoin.DataTypes.sigTxOut = outputs, Simplicity.Bitcoin.DataTypes.sigTxLock = 0}



let sigHashAll = mkSigHashAll tx 0



let r = 0x00000000000000000000003b78ce563f89a0ed9414f5aa28ad0d96d6795f9c63 :: Simplicity.Word.Word256

let schnorrTag = Data.Serialize.encode . Simplicity.Digest.bsHash $ Data.ByteString.Char8.pack "BIPSchnorr"

let e = Simplicity.Digest.integerHash256 . Simplicity.Digest.bsHash $ schnorrTag <> schnorrTag <> Data.Serialize.encode r <> Data.Serialize.encode pubkey <> Data.Serialize.encode sigHashAll

let k = order `div` 2

let sig = Simplicity.LibSecp256k1.Schnorr.Sig r (fromInteger ((k + priv * e) `mod` order))

let binary = makeBinaryProgram $ Simplicity.Bitcoin.Programs.CheckSigHashAll.Lib.pkwCheckSigHashAll pubkey sig



showHash . Simplicity.MerkleRoot.commitmentRoot . parseBinaryProgram $ binary



let disassemble x = Simplicity.Bitcoin.Dag.jetDag (x :: Simplicity.Bitcoin.Dag.JetDag Simplicity.Bitcoin.Jets.JetType () ())

let stripTypeAnnotations = Lens.Family2.set (traverse . Simplicity.Bitcoin.Inference.tyAnnotation) ()

let showAssembly = zipWith (\i x -> show i ++ ": " ++ show (fmap (i -) x)) [0..]

let assembly = showAssembly . stripTypeAnnotations . disassemble . parseBinaryProgram $ binary

let showList = mapM_ putStrLn

let showRange x i a = showList $ (take i . drop x) a



showRange 0 10 assembly



let writeBinaryToFile fn = Data.ByteString.writeFile fn . Data.Serialize.runPut . Simplicity.Serialization.putBitStream

writeBinaryToFile "/dev/shm/checksighashall.simplicity" binary



REDEEM_TX=$(hal psbt finalize $(hal psbt edit --input-idx 0 --final-script-witness $(hexdump -v -e'1/1 "%02x"' /dev/shm/checksighashall.simplicity) $PSBT))



btc decoderawtransaction $REDEEM_T



REDEEM_TXID=$(btc sendrawtransaction $REDEEM_TX)



btc generatetoaddress 1 $ADDRESS



btc gettransaction $REDEEM_TXID



HEX=$(btc gettransaction $REDEEM_TXID | jq '.hex' | tr -d '"')

btc decoderawtransaction $HEX





































