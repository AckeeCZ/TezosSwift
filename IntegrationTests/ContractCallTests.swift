//
//  ContractCallTests.swift
//  IntegrationTests
//
//  Created by Marek Fořt on 11/12/18.
//  Copyright © 2018 Keefer Taylor. All rights reserved.
//

import XCTest
@testable import TezosSwift

class ContractCallTests: XCTestCase {

    let tezosClient = TezosClient(remoteNodeURL: Constants.defaultNodeURL)
    var wallet: Wallet!

    override func setUp() {
        let mnemonic = "soccer click number muscle police corn couch bitter gorilla camp camera shove expire praise pill"
        wallet = Wallet(mnemonic: mnemonic)!
    }

    func testSendingTezos() {
        let testCompletionExpectation = expectation(description: "Sending Tezos")

        tezosClient.send(amount: TezosBalance(balance: 1), to: "KT1UA28DNuXoXNMRjU2HqyrDyCiAmDYnpid9", from: wallet, completion: { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(_):
                testCompletionExpectation.fulfill()
            }
        })

        waitForExpectations(timeout: 3, handler: nil)
    }


    func testSendingIntParam() {
        let testCompletionExpectation = expectation(description: "Sending Tezos with int param")

        tezosClient.call(address: "KT1UA28DNuXoXNMRjU2HqyrDyCiAmDYnpid9", param1: 10, from: wallet, amount: TezosBalance(balance: 1), completion: { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
                testCompletionExpectation.fulfill()
            case .success(_):
                testCompletionExpectation.fulfill()
            }
        })

        waitForExpectations(timeout: 3, handler: nil)
    }
}
