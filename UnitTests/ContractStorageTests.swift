//
//  ContractStorageTests.swift
//  UnitTests
//
//  Created by Marek Fořt on 11/22/18.
//  Copyright © 2018 Keefer Taylor. All rights reserved.
//

import Result
import XCTest
@testable import TezosSwift

class ContractStorageTests: XCTestCase {

    // TODO: Rewrite to unit tests

    func testIntStatus() {
        let networkSessionMock = NetworkSessionMock()
        networkSessionMock.data = """
        {"manager":"tz1XV5grkdVLMC9x5cy8GSPLEuSKQeDi39D5","balance":"123000020","spendable":false,"delegate":{"setable":false},"script":{"code":[{"prim":"parameter","args":[{"prim":"int"}]},{"prim":"storage","args":[{"prim":"int"}]},{"prim":"code","args":[[{"prim":"CAR"},{"prim":"PUSH","args":[{"prim":"int"},{"int":"1"}]},{"prim":"ADD"},{"prim":"NIL","args":[{"prim":"operation"}]},{"prim":"PAIR"}]]}],"storage":{"int":"11"}},"counter":"0"}
        """.data(using: .utf8)!
        let tezosClient = TezosClient(remoteNodeURL: Constants.defaultNodeURL, urlSession: networkSessionMock)
        let testStatusExpectation = expectation(description: "Int status")
        tezosClient.testContract(at: "contract").status { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(let value):
                XCTAssertEqual(value.storage, 11)
                testStatusExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1)
    }

//    func testOptionalNonNilStringStatus() {
//        let urlSessionMock = URLSessionMock()
//        urlSessionMock.data = """
//        {"manager":"tz1XV5grkdVLMC9x5cy8GSPLEuSKQeDi39D5","balance":"123000020","spendable":false,"delegate":{"setable":false},"script":{"code":[{"prim":"parameter","args":[{"prim":"int"}]},{"prim":"storage","args":[{"prim":"int"}]},{"prim":"code","args":[[{"prim":"CAR"},{"prim":"PUSH","args":[{"prim":"int"},{"int":"1"}]},{"prim":"ADD"},{"prim":"NIL","args":[{"prim":"operation"}]},{"prim":"PAIR"}]]}],"storage":{"int":"11"}},"counter":"0"})
//        """.data(using: .utf8)!
//        let testStatusExpectation = expectation(description: "Optional non-nil string status")
//        tezosClient.optionalStringContract(at: "KT1Rh4iEMxBLJbDbz7iAB6FGLJ3mSCx3qFrW").status { result in
//            switch result {
//            case .failure(let error):
//                XCTFail("Failed with error: \(error)")
//            case .success(let value):
//                XCTAssertEqual(value.storage, "hello")
//                testStatusExpectation.fulfill()
//            }
//        }
//
//        waitForExpectations(timeout: 3)
//    }
}


class NetworkSessionMock: NetworkSession {
    var data: Data?
    var error: Error?
    var response = HTTPURLResponse(url: URL(string: "https://google.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)

    func loadData(with urlRequest: URLRequest,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)  {
        completionHandler(data, response, error)
    }
}
