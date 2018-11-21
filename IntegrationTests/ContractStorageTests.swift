//
//  ContractStorageTests.swift
//  IntegrationTests
//
//  Created by Marek Fořt on 11/12/18.
//  Copyright © 2018 Keefer Taylor. All rights reserved.
//

import XCTest
@testable import TezosSwift 

class ContractStorageTests: XCTestCase {

    let tezosClient = TezosClient(remoteNodeURL: Constants.defaultNodeURL)

    // TODO: Rewrite to unit tests

    func testIntStatus() {
        let testStatusExpectation = expectation(description: "Int status")
        tezosClient.testContract(at: "KT1UA28DNuXoXNMRjU2HqyrDyCiAmDYnpid9").status { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(let value):
                XCTAssertEqual(value.storage, 11)
                testStatusExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 3)
    }

    func testOptionalNonNilStringStatus() {
        let testStatusExpectation = expectation(description: "Optional non-nil string status")
        tezosClient.optionalStringContract(at: "KT1Rh4iEMxBLJbDbz7iAB6FGLJ3mSCx3qFrW").status { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(let value):
                XCTAssertEqual(value.storage, "hello")
                testStatusExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 3)
    }

    func testOptionalNilStringStatus() {
        let testStatusExpectation = expectation(description: "Optional nil string status")
        tezosClient.optionalStringContract(at: "KT1F3NKYP1NcpHGKW23ch8NvB436r1LXvUJN").status { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(let value):
                XCTAssertNil(value.storage)
                testStatusExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 3)
    }

    func testOptionalPairBoolStatus() {
        let testStatusExpectation = expectation(description: "Optional pair bool status")
        tezosClient.optiionalPairBoolContract(at: "KT1VMgRT1wcPLcBxeskaXvGYdWqxPPXLz6sp").status { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(let value):
                XCTAssertEqual(value.storage.first, true)
                XCTAssertEqual(value.storage.second, false)
                testStatusExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 3)
    }

    func testPairStatus() {
        let testStatusExpectation = expectation(description: "Pair status")
        tezosClient.pairStatus(of: "KT1VMgRT1wcPLcBxeskaXvGYdWqxPPXLz6sp", completion: { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(let value):
                XCTAssert(value.storage.arg1)
                XCTAssertFalse(value.storage.arg2)
                testStatusExpectation.fulfill()
            }
        })

        waitForExpectations(timeout: 3)
    }

    func testComplicatedPairStatus() {
        let testStatusExpectation = expectation(description: "Complicated status")
        tezosClient.complicatedPairStatus(of: "KT1R5mgZpK7eL7QJ7kmVUzFwX9Kc9FepcUpr", completion: { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(let value):
                XCTAssertEqual(value.storage.arg1, ["Hello", "World"])
                XCTAssertFalse(value.storage.arg2 ?? true)
                testStatusExpectation.fulfill()
            }
        })

        waitForExpectations(timeout: 3)
    }

}
