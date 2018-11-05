//
//  TezosViewController.swift
//  TezosSwift
//
//  Created by Marek Fořt on 11/2/18.
//  Copyright © 2018 Keefer Taylor. All rights reserved.
//

import UIKit

class TezosViewController: UIViewController {

    let tezosClient = TezosClient(remoteNodeURL: Constants.defaultNodeURL)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        // Run some basic tests.
        // TODO: Refactor these to be proper unit tests.
        testWalletGeneration()
//        testWalletGenerationPassPhrase()
        testAddressRPCs()
        //    testCryptoUtils()
    }

    public func testCryptoUtils() {
        let validAddress = "tz1PnyUZjRTFdYbYcJFenMwZanXtVP17scPH"
        let validOriginatedAddress = "KT1Agon3ARPS7U74UedWpR96j1CCbPCsSTsL"
        let invalidAddress = "tz1PnyUZjRTFdYbYcJFenMwZanXtVP17scPh"
        let publicKey = "edpkvESBNf3cbx7sb4CjyurMxFJjCkUVkunDMjsXD4Squoo5nJR4L4"

        print("Validating Addresses")
        print("Expect:  true\nActual:  \(Crypto.validateAddress(address: validAddress))\n")
        print("Expect:  false\nActual:  \(Crypto.validateAddress(address: validOriginatedAddress))\n")
        print("Expect:  false\nActual:  \(Crypto.validateAddress(address: invalidAddress))\n")
        print("Expect:  false\nActual:  \(Crypto.validateAddress(address: publicKey))\n")
        print("")

        let fakeOperation = "123456"
        let wallet = Wallet()!
        let randomWallet = Wallet()!
        let result = Crypto.signForgedOperation(operation: fakeOperation, secretKey: wallet.keys.secretKey)!

        print("Validating Signatures")
        print("Expect:  true\nActual:   \(Crypto.verifyBytes(bytes: result.operationBytes, signature: result.signature, publicKey: wallet.keys.publicKey))\n")
        print("Expect:  false\nActual:   \(Crypto.verifyBytes(bytes: result.operationBytes, signature: result.signature, publicKey: randomWallet.keys.publicKey))\n")
        print("Expect:  false\nActual:   \(Crypto.verifyBytes(bytes: result.operationBytes, signature: [1, 2, 3], publicKey: wallet.keys.publicKey))\n")
        print("")

        print("Testing Key Extraction")
        print("Expected PK: \(wallet.keys.publicKey)")
        print("Actual PK:   \(Crypto.extractPublicKey(secretKey: wallet.keys.secretKey)!)")
        print("")

        print("Expected PKH: \(wallet.address)")
        print("Actual PKH:   \(Crypto.extractPublicKeyHash(secretKey: wallet.keys.secretKey)!)")
        print("")
    }

    private func testWalletGenerationPassPhrase() {
        let passphrase = "TezosKitTest"

        let expectedMnemonic = "soccer click number muscle police corn couch bitter gorilla camp camera shove expire praise pill"
        let expectedPublicKey = "edpktnCgi3C7ZLyLrF4NAebDkgu5PZRRJ9BafxskVEj6U1GycyRird"
        let expectedSecretKey = "edskRjazzmroxmJagYDhCT1jXna8m9H2qvjtPAcrZYZ31og4ud1u2kkxYGv8e7CjmbW33QubzugueXqLFPMbM2eAj6j3AQHrCW"
        let expectedPublicKeyHash = "tz1ZfhME1B2kmagqEJ9P7PE8joM3TbVQ5r4v"

        // Create a wallet.
        guard let wallet = Wallet(mnemonic: expectedMnemonic, passphrase: passphrase) else {
            print("Error creating wallet :(")
            return
        }

        print("Expected Public Key: " + expectedPublicKey)
        print("Actual Public Key  : " + wallet.keys.publicKey)
        print("")

        print("Expected Private Key: " + expectedSecretKey)
        print("Actual Private Key  : " + wallet.keys.secretKey)
        print("")

        print("Expected Hash Key: " + expectedPublicKeyHash)
        print("Actual Hash Key  : " + wallet.address)
        print("")

        print("Expected mnemonic: " + expectedMnemonic)
        print("Actual mnemonic  : " + wallet.mnemonic!)
        print("")

        // tz1XV5grkdVLMC9x5cy8GSPLEuSKQeDi39D5
        tezosClient.send(amount: TezosBalance(balance: 1), to: "KT1UA28DNuXoXNMRjU2HqyrDyCiAmDYnpid9", from: wallet.address, keys: wallet.keys, completion: { result in
            print("Send tezos successful:")
            print(result.value)
            print(result.error)
            print(wallet.address)
        })

    }

    private func testWalletGeneration() {

        // Params for a wallet. This wallet is never originated and should *NOT* be used as the secret
        // key will live in github.
        //        let expectedPublicKey = "edpku9ZF6UUAEo1AL3NWy1oxHLL6AfQcGYwA5hFKrEKVHMT3Xx889A"
        //        let expectedSecretKey =
        //            "edskS4pbuA7rwMjsZGmHU18aMP96VmjegxBzwMZs3DrcXHcMV7VyfQLkD5pqEE84wAMHzi8oVZF6wbgxv3FKzg7cLqzURjaXUp"
        let expectedPublicKeyHash = "tz1Y3qqTg9HdrzZGbEjiCPmwuZ7fWVxpPtRw"
        let expectedMnemonic = "soccer click number muscle police corn couch bitter gorilla camp camera shove expire praise pill"

        // Create a wallet.
        guard let wallet = Wallet(mnemonic: expectedMnemonic) else {
            print("Error creating wallet :(")
            return
        }

        //        print("Testing generating wallet with mnemonic")
        //        print("")
        //
        //        print("Expected Public Key: " + expectedPublicKey)
        //        print("Actual Public Key  : " + wallet.keys.publicKey)
        //        print("")
        //
        //        print("Expected Private Key: " + expectedSecretKey)
        //        print("Actual Private Key  : " + wallet.keys.secretKey)
        //        print("")
        //
        //        print("Expected Hash Key: " + expectedPublicKeyHash)
        //        print("Actual Hash Key  : " + wallet.address)
        //        print("")
        //
        //        print("Expected mnemonic: " + expectedMnemonic)
        //        print("Actual mnemonic  : " + wallet.mnemonic!)
        //        print("")
        //
        //        print("Testing generating wallet from secretKey")
        //        print("")

        guard let restoredWallet = Wallet(secretKey: wallet.keys.secretKey) else {
            print("Error restoring wallet :(")
            return
        }

        //        print("Expected Public Key: " + expectedPublicKey)
        //        print("Actual Public Key  : " + restoredWallet.keys.publicKey)
        //        print("")
        //
        //        print("Expected Private Key: " + expectedSecretKey)
        //        print("Actual Private Key  : " + restoredWallet.keys.secretKey)
        //        print("")

        print("Expected Hash Key: " + expectedPublicKeyHash)
        print("Actual Hash Key  : " + restoredWallet.address)
        print("")

        tezosClient.send(amount: TezosBalance(balance: 1), to: "KT1UA28DNuXoXNMRjU2HqyrDyCiAmDYnpid9", from: wallet.address, keys: wallet.keys, completion: { result in
            print("Send tezos successful:")
            print(result.value)
            print(result.error)
            print(wallet.address)
        })
    }

    private func testAddressRPCs() {
        let tezosClient = TezosClient(remoteNodeURL: Constants.defaultNodeURL)

        // Originated account for Tezos.Community.
        // See: KT1BVAXZQUc4BGo3WTJ7UML6diVaEbe4bLZA
        let address = "KT1UA28DNuXoXNMRjU2HqyrDyCiAmDYnpid9"

        tezosClient.balance(of: address, completion: { result in
            print("Balance:")
            print(result.value?.humanReadableRepresentation)
        })

        tezosClient.chainHead(completion: { result in
            print("Chain")
            print(result.value)
        })

        tezosClient.delegate(of: address, completion: { result in
            print("Delegate:")
            print(result.value)
        })

        tezosClient.status(of: address, completion: { result in
            print("Status:")
            print(result.value)
        })
    }
}
