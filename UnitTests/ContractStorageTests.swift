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
        {"manager":"tz1XV5grkdVLMC9x5cy8GSPLEuSKQeDi39D5","balance":"123000020","spendable":false,"delegate":{"setable":false},"script":{"code":[{"prim":"parameter","args":[{"prim":"string"}]},{"prim":"storage","args":[{"prim":"option","args":[{"prim":"string"}]}]},{"prim":"code","args":[[{"prim":"CAR"},{"prim":"SOME"},{"prim":"NIL","args":[{"prim":"operation"}]},{"prim":"PAIR"}]]}],"storage":{"prim":"Some","args":[{"string":"hello"}]}},"counter":"0"}
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

    func testOrSwapStatus() {
        let networkSessionMock = NetworkSessionMock()
        networkSessionMock.data = """
        {"manager":"tz1XV5grkdVLMC9x5cy8GSPLEuSKQeDi39D5","balance":"100000000","spendable":false,"delegate":{"setable":false},"script":{"code":[{"prim":"parameter","args":[{"prim":"or","args":[{"prim":"bool"},{"prim":"string"}]}]},{"prim":"storage","args":[{"prim":"or","args":[{"prim":"string"},{"prim":"bool"}]}]},{"prim":"code","args":[[{"prim":"CAR"},{"prim":"IF_LEFT","args":[[{"prim":"RIGHT","args":[{"prim":"string"}]}],[{"prim":"LEFT","args":[{"prim":"bool"}]}]]},{"prim":"NIL","args":[{"prim":"operation"}]},{"prim":"PAIR"}]]}],"storage":{"prim":"Left","args":[{"string":"X"}]}},"counter":"0"}
        """.data(using: .utf8)!
        let tezosClient = TezosClient(remoteNodeURL: Constants.defaultNodeURL, urlSession: networkSessionMock)
        let testStatusExpectation = expectation(description: "Or swap status")
        tezosClient.orSwapContract(at: "contract").status { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(let value):
                XCTAssertEqual(value.storage.arg1, "X")
                XCTAssertNil(value.storage.arg2)
                testStatusExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1)
    }

    func testKeyHashStatus() {
        let networkSessionMock = NetworkSessionMock()
        networkSessionMock.data = """
        {"manager":"tz1XV5grkdVLMC9x5cy8GSPLEuSKQeDi39D5","balance":"1000000","spendable":false,"delegate":{"setable":false},"script":{"code":[{"prim":"parameter","args":[{"prim":"key_hash"}]},{"prim":"storage","args":[{"prim":"key_hash"}]},{"prim":"code","args":[[{"prim":"CDR"},{"prim":"NIL","args":[{"prim":"operation"}]},{"prim":"PAIR"}]]}],"storage":{"string":"tz1Y3qqTg9HdrzZGbEjiCPmwuZ7fWVxpPtRw"}},"counter":"0"}
        """.data(using: .utf8)!
        let tezosClient = TezosClient(remoteNodeURL: Constants.defaultNodeURL, urlSession: networkSessionMock)
        let testStatusExpectation = expectation(description: "Or swap status")
        tezosClient.keyHashContract(at: "contract").status { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(let value):
                XCTAssertEqual(value.storage, "tz1Y3qqTg9HdrzZGbEjiCPmwuZ7fWVxpPtRw")
                testStatusExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1)
    }

    func testParameterPairStatus() {
        let networkSessionMock = NetworkSessionMock()
        networkSessionMock.data = """
        {"manager":"tz1XV5grkdVLMC9x5cy8GSPLEuSKQeDi39D5","balance":"1000000","spendable":false,"delegate":{"setable":false},"script":{"code":[{"prim":"parameter","args":[{"prim":"pair","args":[{"prim":"bool","annots":["%first"]},{"prim":"bool","annots":["%second"]}],"annots":[":param"]}]},{"prim":"storage","args":[{"prim":"option","args":[{"prim":"bool"}]}]},{"prim":"code","args":[[{"prim":"CAR"},[[{"prim":"DUP"},{"prim":"CAR"},{"prim":"DIP","args":[[{"prim":"CDR"}]]}]],{"prim":"AND","annots":["@and"]},{"prim":"SOME","annots":["@res"]},{"prim":"NIL","args":[{"prim":"operation"}],"annots":["@noop"]},{"prim":"PAIR"},[[{"prim":"DUP"},{"prim":"CAR","annots":["@x"]},{"prim":"DIP","args":[[{"prim":"CDR","annots":["@y"]}]]}]],{"prim":"PAIR","annots":["%a","%b"]}]]}],"storage":{"prim":"Some","args":[{"prim":"False"}]}},"counter":"0"}
        """.data(using: .utf8)!
        let tezosClient = TezosClient(remoteNodeURL: Constants.defaultNodeURL, urlSession: networkSessionMock)
        let testStatusExpectation = expectation(description: "Parameter pair status")
        tezosClient.parameterPairContract(at: "contract").status { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(let value):
                XCTAssertEqual(value.storage, false)
                testStatusExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1)
    }

    func testMutezStatus() {
        let networkSessionMock = NetworkSessionMock()
        networkSessionMock.data = """
        {"manager":"tz1XV5grkdVLMC9x5cy8GSPLEuSKQeDi39D5","balance":"1000000","spendable":false,"delegate":{"setable":false},"script":{"code":[{"prim":"parameter","args":[{"prim":"mutez"}]},{"prim":"storage","args":[{"prim":"mutez"}]},{"prim":"code","args":[[{"prim":"CDR"},{"prim":"NIL","args":[{"prim":"operation"}]},{"prim":"PAIR"}]]}],"storage":{"int":"100"}},"counter":"0"}
        """.data(using: .utf8)!
        let tezosClient = TezosClient(remoteNodeURL: Constants.defaultNodeURL, urlSession: networkSessionMock)
        let testStatusExpectation = expectation(description: "Mutez status")
        tezosClient.mutezContract(at: "contract").status { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(let value):
                XCTAssertEqual(value.storage, Mutez(100))
                testStatusExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1)
    }

    func testMapStatus() {
        let networkSessionMock = NetworkSessionMock()
        networkSessionMock.data = """
        {"manager":"tz1XV5grkdVLMC9x5cy8GSPLEuSKQeDi39D5","balance":"1000000","spendable":false,"delegate":{"setable":false},"script":{"code":[{"prim":"parameter","args":[{"prim":"map","args":[{"prim":"int"},{"prim":"int"}]}]},{"prim":"storage","args":[{"prim":"map","args":[{"prim":"int"},{"prim":"int"}]}]},{"prim":"code","args":[[{"prim":"CDR"},{"prim":"NIL","args":[{"prim":"operation"}]},{"prim":"PAIR"}]]}],"storage":[{"prim":"Elt","args":[{"int":"0"},{"int":"100"}]},{"prim":"Elt","args":[{"int":"2"},{"int":"100"}]}]},"counter":"0"}
        """.data(using: .utf8)!
        let tezosClient = TezosClient(remoteNodeURL: Constants.defaultNodeURL, urlSession: networkSessionMock)
        let testStatusExpectation = expectation(description: "Map status")
        tezosClient.mapContract(at: "contract").status { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(let value):
                XCTAssertEqual(value.storage.first?.0, 0)
                XCTAssertEqual(value.storage.first?.1, 100)
                XCTAssertEqual(value.storage.last?.0, 2)
                XCTAssertEqual(value.storage.last?.1, 100)
                testStatusExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1)
    }

    func testKeyStatus() {
        let networkSessionMock = NetworkSessionMock()
        networkSessionMock.data = """
        {"manager":"tz1XV5grkdVLMC9x5cy8GSPLEuSKQeDi39D5","balance":"100000000","spendable":false,"delegate":{"setable":false},"script":{"code":[{"prim":"parameter","args":[{"prim":"key"}]},{"prim":"storage","args":[{"prim":"key"}]},{"prim":"code","args":[[{"prim":"CDR"},{"prim":"NIL","args":[{"prim":"operation"}]},{"prim":"PAIR"}]]}],"storage":{"string":"edpkuBknW28nW72KG6RoHtYW7p12T6GKc7nAbwYX5m8Wd9sDVC9yav"}},"counter":"0"}
        """.data(using: .utf8)!
        let tezosClient = TezosClient(remoteNodeURL: Constants.defaultNodeURL, urlSession: networkSessionMock)
        let testStatusExpectation = expectation(description: "Map status")
        tezosClient.keyContract(at: "contract").status { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success(let value):
                XCTAssertEqual(value.storage, "edpkuBknW28nW72KG6RoHtYW7p12T6GKc7nAbwYX5m8Wd9sDVC9yav")
                testStatusExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1)
    }
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
