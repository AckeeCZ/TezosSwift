//
//  ContractStorageTests.swift
//  IntegrationTests
//
//  Created by Marek Fořt on 11/12/18.
//  Copyright © 2018 Keefer Taylor. All rights reserved.
//

import XCTest
import TezosSwift
@testable import TezosSwift_Example

class ContractStorageTests: XCTestCase {

    let tezosClient = TezosClient(remoteNodeURL: Constants.defaultNodeURL)

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
        tezosClient.stringOptionalContract(at: "KT1Rh4iEMxBLJbDbz7iAB6FGLJ3mSCx3qFrW").status { result in
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
        tezosClient.stringOptionalContract(at: "KT1F3NKYP1NcpHGKW23ch8NvB436r1LXvUJN").status { result in
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
        tezosClient.optionalPairBoolContract(at: "KT1VMgRT1wcPLcBxeskaXvGYdWqxPPXLz6sp").status { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(let value):
                XCTAssertEqual(value.storage.arg1, true)
                XCTAssertEqual(value.storage.arg2, false)
                testStatusExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 3)
    }

    func testStringSetStatus() {
        let testStatusExpectation = expectation(description: "String set status")
        tezosClient.stringSetContract(at: "KT1E9795k5yXPV7P7nhoHXtwvaaDo7dNcHC3").status { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(let value):
                XCTAssertEqual(value.storage, ["a", "b", "c"])
                testStatusExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 3)
    }

    func testOrSwapStatus() {
        let testStatusExpectation = expectation(description: "Or swap status")
        tezosClient.orSwapContract(at: "KT1WMUFDxTB2QkyYZnVKm6KZpyvWpKn7nLdP").status { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(let value):
                XCTAssertEqual(value.storage.arg1, "X")
                XCTAssertNil(value.storage.arg2)
                testStatusExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 3)
    }

    func testKeyHashStatus() {
        let testStatusExpectation = expectation(description: "Key hash status")
        tezosClient.keyHashContract(at: "KT1BdTKRWed7V1bT4jgtwkG4k7MgUTAC1Jaj").status { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(let value):
                XCTAssertEqual(value.storage, "tz1Y3qqTg9HdrzZGbEjiCPmwuZ7fWVxpPtRw")
                testStatusExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 3)
    }

    func testParameterPairStatus() {
        let testStatusExpectation = expectation(description: "Parameter pair status")
        tezosClient.parameterPairContract(at: "KT1Rfr8ywXgj4QmGpvoWuJD4XvFMrFhK7D9m").status { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(let value):
                XCTAssertEqual(value.storage, false)
                testStatusExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 3)
    }
    
    func testRateContractStatus() {
        let testStatusExpectation = expectation(description: "Rate contract status")
        tezosClient.rateContract(at: "KT1EDS35c3a7unangqgnijm1oSZduuWpRqHP").status { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(let value):
                break
            }
            testStatusExpectation.fulfill()
        }

        waitForExpectations(timeout: 3)
    }
}

