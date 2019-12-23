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
        super.setUp()
        wallet = Wallet(secretKey: "edskS8prNjez35pfbMSQARwg9fzMoGh613uriXtnGCSwVk5FX1Ee9Sd4FHKrgxTje2XEfA78SytvyKFbnAKFjvVbpQMXnzqT8Z")!
    }

    // TODO: Change calling of these calls, so the counter does not conflict
    // These calls have to be executed individually for now
    func testSendingTezos() {
        let testCompletionExpectation = expectation(description: "Sending Tezos")
        let operationFees = OperationFees(fee: Tez(0.001272), gasLimit: Tez(0.010000), storageLimit: Tez(0))
        tezosClient.send(amount: Tez(1), to: "tz1dD918PXDuUHV6Mh6z2QqMukA67YULuhqd", from: wallet, operationFees: operationFees, completion: { result in
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

    func testSendingEmptyStringParam() {
        let testCompletionExpectation = expectation(description: "Sending Tezos with int param")
        tezosClient.stringOptionalContract(at: "KT1F3NKYP1NcpHGKW23ch8NvB436r1LXvUJN").call(nil).send(from: wallet, amount: Tez(1), completion: { result in
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
        tezosClient.stringOptionalContract(at: "KT1Rh4iEMxBLJbDbz7iAB6FGLJ3mSCx3qFrW").call("hello").send(from: wallet, amount: Tez(1), completion: { result in
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
        tezosClient.testContract(at: "KT1UA28DNuXoXNMRjU2HqyrDyCiAmDYnpid9").call(10).send(from: wallet, amount: Mutez(1), completion: { result in
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
    
    func testSendingToRateContract() {
        let testCompletionExpectation = expectation(description: "Sending Tezos with rate contract")
        wallet = Wallet(secretKey: "edskS8prNjez35pfbMSQARwg9fzMoGh613uriXtnGCSwVk5FX1Ee9Sd4FHKrgxTje2XEfA78SytvyKFbnAKFjvVbpQMXnzqT8Z")!
        tezosClient.rateContract(at: "KT1SwMaeEygYz8MuK3jjUFAUen7xRXGkxTyP").vote(["tz1S8g2w1YCzFwueTNweWPnA852mgCeXpsEu": 1]).send(from: wallet, amount: Tez(1), completion: { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
                print(error)
                testCompletionExpectation.fulfill()
            case .success(_):
                testCompletionExpectation.fulfill()
            }
        })

        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testEndingRateContract() {
        let testCompletionExpectation = expectation(description: "Sending Tezos with rate contract")
        wallet = Wallet(secretKey: "edskS8prNjez35pfbMSQARwg9fzMoGh613uriXtnGCSwVk5FX1Ee9Sd4FHKrgxTje2XEfA78SytvyKFbnAKFjvVbpQMXnzqT8Z")!
        tezosClient.rateContract(at: "KT1SwMaeEygYz8MuK3jjUFAUen7xRXGkxTyP").end().send(from: wallet, amount: Tez(1), completion: { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
                print(error)
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

        tezosClient.packUnpackContract(at: "KT1REVKi3gDXZ6H1AUp3UzpfC2YUmuM9tfRp").call(param1: "toto", param2: [1, 2], param3: [3, 4], param4: "hello".data(using: .utf8)!).send(from: wallet, amount: Tez(1), completion: { result in
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

        tezosClient.bytesContract(at: "KT1Hbpgho8jUJp6AY2dh1pq61u7b2in1f9DA").call("".data(using: .utf8)!).send(from: wallet, amount: Tez(1), completion: { result in
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

        tezosClient.orSwapContract(at: "KT1WMUFDxTB2QkyYZnVKm6KZpyvWpKn7nLdP").call("X").send(from: wallet, amount: Tez(1), completion: { result in
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

        tezosClient.keyHashContract(at: "KT1BdTKRWed7V1bT4jgtwkG4k7MgUTAC1Jaj").call("tz1Y3qqTg9HdrzZGbEjiCPmwuZ7fWVxpPtRw").send(from: wallet, amount: Tez(1), completion: { result in
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

        tezosClient.mapContract(at: "KT1D9EKXXwhvFDxHYGfuYzr3W4kkKK4nHgDn").call([0: 100, 2: 100]).send(from: wallet, amount: Tez(1), completion: { result in
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

        tezosClient.keyContract(at: "KT18oBBvkyV1AsLUAtbfDJE94TajkJM2fukt").call("edpkuBknW28nW72KG6RoHtYW7p12T6GKc7nAbwYX5m8Wd9sDVC9yav").send(from: wallet, amount: Tez(1), completion: { result in
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

    func testTimestamp() {
        let testCompletionExpectation = expectation(description: "Sending timestampt contract")

        tezosClient.timestampContract(at: "KT1MkVQtRbMH1SY7RXNVPjCjAKRh43UwFf85").call(Date(timeIntervalSince1970: 1502733621)).send(from: wallet, amount: Tez(1), completion: { result in
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

    func testNat() {
        let testCompletionExpectation = expectation(description: "Sending Nat contract")

        tezosClient.natContract(at: "KT1HGVi64Bo2pLjsedTJ8AC3dh6Dpf68KMgw").call(100).send(from: wallet, amount: Tez(1), completion: { result in
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

    func testSetNat() {
        let testCompletionExpectation = expectation(description: "Sending Nat Set contract")
        tezosClient.natSetContract(at: "KT1DwASQY1uTEkzWUShbeQJfKpBdb2ugsE5k").call([1, 2, 3]).send(from: wallet, amount: Tez(1), completion: { result in
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

    func testSendingBatchedOperations() {
        let testCompletionExpectation = expectation(description: "Sending in batch")
        let input: TezosPair<TezosPair<TezosPair<String, [Int]>, [UInt]>, Data> = TezosPair(first: TezosPair(first: TezosPair(first: "toto", second: [3, 7, 9, 1]), second: [UInt(2), UInt(1), UInt(3)].sorted()), second: "hello".data(using: .utf8)!)
        let input2: TezosPair<TezosPair<TezosPair<String, [Int]>, [UInt]>, Data> = TezosPair(first: TezosPair(first: TezosPair(first: "second input", second: [3, 7, 9, 1]), second: [UInt(2), UInt(1), UInt(3)].sorted()), second: "hello".data(using: .utf8)!)
        let contractOperation = ContractOperation(amount: Tez(1), source: "tz1WRFiK6eGNvP3ioWkWeP6JwDaQjj95opnQ", destination: "KT1REVKi3gDXZ6H1AUp3UzpfC2YUmuM9tfRp", input: input, operationName: "default")
        let contractOperation2 = ContractOperation(amount: Tez(1), source: "tz1WRFiK6eGNvP3ioWkWeP6JwDaQjj95opnQ", destination: "KT1REVKi3gDXZ6H1AUp3UzpfC2YUmuM9tfRp", input: input2, operationName: "default")
        tezosClient.forgeSignPreapplyAndInjectOperations(operations: [contractOperation, contractOperation2], source: "tz1WRFiK6eGNvP3ioWkWeP6JwDaQjj95opnQ", keys: wallet.keys, completion: { result in
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
