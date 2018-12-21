//
//  TezosRPCTests.swift
//  UnitTests
//
//  Created by Marek Fořt on 12/13/18.
//  Copyright © 2018 Ackee. All rights reserved.
//

import XCTest
import Foundation
import TezosSwift
@testable import TezosSwift_Example

class TezosRPCTests: XCTestCase {
    func testCurrentPeriodKind() {
        let networkSessionMock = NetworkSessionMock()
        networkSessionMock.data = "proposal".data(using: .utf8)!
        let tezosClient = TezosClient(remoteNodeURL: Constants.defaultNodeURL, urlSession: networkSessionMock)
        let completionExpectation = expectation(description: "Period kind")
        tezosClient.currentPeriodKind { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(let value):
                XCTAssertEqual(value, .proposal)
                completionExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1)
    }

    func testDelegatesList() {
        let networkSessionMock = NetworkSessionMock()
        networkSessionMock.data = """
        [{"pkh":"tz3gN8NTLNLJg5KRsUU47NHNVHbdhcFXjjaB","rolls":817},{"pkh":"tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5","rolls":817},{"pkh":"tz3NdTPb3Ax2rVW2Kq9QEdzfYFkRwhrQRPhX","rolls":306}]
        """.data(using: .utf8)!
        let tezosClient = TezosClient(remoteNodeURL: Constants.defaultNodeURL, urlSession: networkSessionMock)
        let completionExpectation = expectation(description: "Delegates list")
        tezosClient.delegatesList { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(let value):
                XCTAssertEqual(value.first?.address, "tz3gN8NTLNLJg5KRsUU47NHNVHbdhcFXjjaB")
                XCTAssertEqual(value.first?.rollsCount, 817)
                completionExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1)
    }

    func testBallotsSum() {
        let networkSessionMock = NetworkSessionMock()
        networkSessionMock.data = """
        {"yay":1,"nay":3,"pass":2}
        """.data(using: .utf8)!
        let tezosClient = TezosClient(remoteNodeURL: Constants.defaultNodeURL, urlSession: networkSessionMock)
        let completionExpectation = expectation(description: "Period kind")
        tezosClient.ballotsSum { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(let value):
                XCTAssertEqual(value.yayCount, 1)
                XCTAssertEqual(value.nayCount, 3)
                XCTAssertEqual(value.passCount, 2)
                completionExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1)
    }
}

