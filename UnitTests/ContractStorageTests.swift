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

    func testOptionalNonNilStringStatus() {
        let networkSessionMock = NetworkSessionMock()
        networkSessionMock.data = """
        {"manager":"tz1XV5grkdVLMC9x5cy8GSPLEuSKQeDi39D5","balance":"100000000","spendable":false,"delegate":{"setable":false},"script":{"code":[{"prim":"parameter","args":[{"prim":"string"}]},{"prim":"storage","args":[{"prim":"option","args":[{"prim":"string"}]}]},{"prim":"code","args":[[{"prim":"CAR"},{"prim":"SOME"},{"prim":"NIL","args":[{"prim":"operation"}]},{"prim":"PAIR"}]]}],"storage":{"prim":"Some","args":[{"string":"hello"}]}},"counter":"0"}
        """.data(using: .utf8)!
        let tezosClient = TezosClient(remoteNodeURL: Constants.defaultNodeURL, urlSession: networkSessionMock)
        let testStatusExpectation = expectation(description: "Optional non-nil string status")
        tezosClient.optionalStringContract(at: "contract").status { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(let value):
                XCTAssertEqual(value.storage, "hello")
                testStatusExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1)
    }

    func testOptionalNilStringStatus() {
        let networkSessionMock = NetworkSessionMock()
        networkSessionMock.data = """
        {"manager":"tz1XV5grkdVLMC9x5cy8GSPLEuSKQeDi39D5","balance":"100000000","spendable":false,"delegate":{"setable":false},"script":{"code":[{"prim":"parameter","args":[{"prim":"string"}]},{"prim":"storage","args":[{"prim":"option","args":[{"prim":"string"}]}]},{"prim":"code","args":[[{"prim":"CAR"},{"prim":"SOME"},{"prim":"NIL","args":[{"prim":"operation"}]},{"prim":"PAIR"}]]}],"storage":{"prim":"None"}},"counter":"0"}
        """.data(using: .utf8)!
        let tezosClient = TezosClient(remoteNodeURL: Constants.defaultNodeURL, urlSession: networkSessionMock)
        let testStatusExpectation = expectation(description: "Optional nil string status")
        tezosClient.optionalStringContract(at: "contract").status { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(let value):
                XCTAssertNil(value.storage)
                testStatusExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1)
    }

    func testOptionalPairBoolStatus() {
        let networkSessionMock = NetworkSessionMock()
        networkSessionMock.data = """
        {"manager":"tz1XV5grkdVLMC9x5cy8GSPLEuSKQeDi39D5","balance":"100000000","spendable":false,"delegate":{"setable":false},"script":{"code":[{"prim":"parameter","args":[{"prim":"pair","args":[{"prim":"bool"},{"prim":"bool"}]}]},{"prim":"storage","args":[{"prim":"option","args":[{"prim":"pair","args":[{"prim":"bool"},{"prim":"bool"}]}]}]},{"prim":"code","args":[[{"prim":"CAR"},{"prim":"SOME"},{"prim":"NIL","args":[{"prim":"operation"}]},{"prim":"PAIR"}]]}],"storage":{"prim":"Some","args":[{"prim":"Pair","args":[{"prim":"True"},{"prim":"False"}]}]}},"counter":"0"}
        """.data(using: .utf8)!
        let tezosClient = TezosClient(remoteNodeURL: Constants.defaultNodeURL, urlSession: networkSessionMock)
        let testStatusExpectation = expectation(description: "Optional pair bool status")
        tezosClient.optionalPairBoolContract(at: "contract").status { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(let value):
                XCTAssertEqual(value.storage.arg1, true)
                XCTAssertEqual(value.storage.arg2, false)
                testStatusExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1)
    }

    func testStringSetStatus() {
        let networkSessionMock = NetworkSessionMock()
        networkSessionMock.data = """
        {"manager":"tz1XV5grkdVLMC9x5cy8GSPLEuSKQeDi39D5","balance":"100000000","spendable":false,"delegate":{"setable":false},"script":{"code":[{"prim":"parameter","args":[{"prim":"set","args":[{"prim":"string"}]}]},{"prim":"storage","args":[{"prim":"set","args":[{"prim":"string"}]}]},{"prim":"code","args":[[{"prim":"CAR"},{"prim":"NIL","args":[{"prim":"operation"}]},{"prim":"PAIR"}]]}],"storage":[{"string":"a"},{"string":"b"},{"string":"c"}]},"counter":"0"}
        """.data(using: .utf8)!
        let tezosClient = TezosClient(remoteNodeURL: Constants.defaultNodeURL, urlSession: networkSessionMock)
        let testStatusExpectation = expectation(description: "String set status")
        tezosClient.stringSetContract(at: "contract").status { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(let value):
                XCTAssertEqual(value.storage, ["a", "b", "c"])
                testStatusExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1)
    }

    func testBytesStatus() {
        let networkSessionMock = NetworkSessionMock()
        networkSessionMock.data = """
        {"manager":"tz1XV5grkdVLMC9x5cy8GSPLEuSKQeDi39D5","balance":"101000000","spendable":false,"delegate":{"setable":false},"script":{"code":[{"prim":"parameter","args":[{"prim":"bytes"}]},{"prim":"storage","args":[{"prim":"bytes"}]},{"prim":"code","args":[[{"prim":"CAR"},{"prim":"NIL","args":[{"prim":"operation"}]},{"prim":"PAIR"}]]}],"storage":{"bytes":""}},"counter":"0"}
        """.data(using: .utf8)!
        let tezosClient = TezosClient(remoteNodeURL: Constants.defaultNodeURL, urlSession: networkSessionMock)
        let testStatusExpectation = expectation(description: "String set status")
        tezosClient.bytesContract(at: "contract").status { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(_):
                testStatusExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1)
    }

//    func testComplicatedPairStatus() {
//        let testStatusExpectation = expectation(description: "Complicated status")
//        tezosClient.complicatedPairStatus(of: "KT1R5mgZpK7eL7QJ7kmVUzFwX9Kc9FepcUpr", completion: { result in
//            switch result {
//            case .failure(let error):
//                XCTFail("Failed with error: \(error)")
//            case .success(let value):
//                XCTAssertEqual(value.storage.arg1, ["Hello", "World"])
//                XCTAssertFalse(value.storage.arg2 ?? true)
//                testStatusExpectation.fulfill()
//            }
//        })
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
