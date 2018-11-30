//
//  ContractCallTests.swift
//  IntegrationTests
//
//  Created by Marek Fořt on 11/12/18.
//  Copyright © 2018 Keefer Taylor. All rights reserved.
//

import XCTest
import TezosSwift
@testable import TezosSwift_Example

class ContractCallTests: XCTestCase {

    let tezosClient = TezosClient(remoteNodeURL: Constants.defaultNodeURL)
    var wallet: Wallet!

    override func setUp() {
        let mnemonic = "soccer click number muscle police corn couch bitter gorilla camp camera shove expire praise pill"
        wallet = Wallet(mnemonic: mnemonic)!
    }

    // TODO: Change calling of these calls, so the counter does not conflict
    // These calls have to be executed individually for now
    func testSendingTezos() {
        let testCompletionExpectation = expectation(description: "Sending Tezos")

        tezosClient.send(amount: Tez(1), to: "KT1UA28DNuXoXNMRjU2HqyrDyCiAmDYnpid9", from: wallet, completion: { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(_):
                testCompletionExpectation.fulfill()
            }
        })

        waitForExpectations(timeout: 3, handler: nil)
    }

    func testSendingEmptyStringParam() {
        let testCompletionExpectation = expectation(description: "Sending Tezos with int param")
        tezosClient.optionalStringContract(at: "KT1F3NKYP1NcpHGKW23ch8NvB436r1LXvUJN").call(param1: nil).send(from: wallet, amount: Tez(1), completion: { result in
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

    func testSendingNonEmptyStringParam() {
        let testCompletionExpectation = expectation(description: "Sending Tezos with int param")
        tezosClient.optionalStringContract(at: "KT1Rh4iEMxBLJbDbz7iAB6FGLJ3mSCx3qFrW").call(param1: "hello").send(from: wallet, amount: Tez(1), completion: { result in
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

    func testSendingIntParam() {
        let testCompletionExpectation = expectation(description: "Sending Tezos with int param")
        tezosClient.testContract(at: "KT1UA28DNuXoXNMRjU2HqyrDyCiAmDYnpid9").call(param1: 10).send(from: wallet, amount: Mutez(1), completion: { result in
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

    func testSendingPairBoolParam() {
        let testCompletionExpectation = expectation(description: "Sending Tezos with int param")
        tezosClient.optionalPairBoolContract(at: "KT1VMgRT1wcPLcBxeskaXvGYdWqxPPXLz6sp").call(param1: true, param2: false).send(from: wallet, amount: Tez(1), completion: { result in
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

    func testPackUnpack() {
        let testCompletionExpectation = expectation(description: "Sending Tezos to PackUnpack contract")

        tezosClient.packUnpackContract(at: "KT1F2aWqKZ8FSmFsTnkUW2wHgNtsRp4nnCEC").call(param1: "hello", param2: [1, 2], param3: [3, 4], param4: "".data(using: .utf8)!).send(from: wallet, amount: Tez(1), completion: { result in
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

    func testBytes() {
        let testCompletionExpectation = expectation(description: "Sending Tezos to PackUnpack contract")

        tezosClient.bytesContract(at: "KT1Hbpgho8jUJp6AY2dh1pq61u7b2in1f9DA").call(param1: "".data(using: .utf8)!).send(from: wallet, amount: Tez(1), completion: { result in
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

    func testOrSwap() {
        let testCompletionExpectation = expectation(description: "Sending Tezos to OrSwap contract")

        tezosClient.orSwapContract(at: "KT1WMUFDxTB2QkyYZnVKm6KZpyvWpKn7nLdP").call(param1: nil, param2: "X").send(from: wallet, amount: Tez(1), completion: { result in
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

    func testKeyHash() {
        let testCompletionExpectation = expectation(description: "Sending Tezos to OrSwap contract")

        tezosClient.keyHashContract(at: "KT1BdTKRWed7V1bT4jgtwkG4k7MgUTAC1Jaj").call(param1: "tz1Y3qqTg9HdrzZGbEjiCPmwuZ7fWVxpPtRw").send(from: wallet, amount: Tez(1), completion: { result in
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

    func testAnnotatedContractPair() {
        let testCompletionExpectation = expectation(description: "Sending Tezos to OrSwap contract")

        tezosClient.parameterPairContract(at: "KT1Rfr8ywXgj4QmGpvoWuJD4XvFMrFhK7D9m").call(first: true, second: false).send(from: wallet, amount: Tez(1), completion: { result in
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

    func testMap() {
        let testCompletionExpectation = expectation(description: "Sending Map contract")

        tezosClient.mapContract(at: "KT1D9EKXXwhvFDxHYGfuYzr3W4kkKK4nHgDn").call(param1: [(0, 100), (2, 100)]).send(from: wallet, amount: Tez(1), completion: { result in
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

    func testKey() {
        let testCompletionExpectation = expectation(description: "Sending Map contract")

        tezosClient.keyContract(at: "KT18oBBvkyV1AsLUAtbfDJE94TajkJM2fukt").call(param1: "edpkuBknW28nW72KG6RoHtYW7p12T6GKc7nAbwYX5m8Wd9sDVC9yav").send(from: wallet, amount: Tez(1), completion: { result in
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
