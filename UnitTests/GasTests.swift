//
//  GasTests.swift
//  UnitTests
//
//  Created by Marek Fořt on 12/13/18.
//  Copyright © 2018 Ackee. All rights reserved.
//

import XCTest
import TezosSwift
@testable import TezosSwift_Example

class GasTests: XCTestCase {

    func testGasDecoding() {
        let networkSessionMock = NetworkSessionMock()
        networkSessionMock.data = """
        {"contents":[{"kind":"transaction","source":"tz1WRFiK6eGNvP3ioWkWeP6JwDaQjj95opnQ","fee":"0","counter":"619","gas_limit":"400000","storage_limit":"60000","amount":"1000000","destination":"KT1DwASQY1uTEkzWUShbeQJfKpBdb2ugsE5k","parameters":[{"int":"1"},{"int":"2"},{"int":"3"}],"metadata":{"balance_updates":[],"operation_result":{"status":"applied","storage":[{"int":"1"},{"int":"2"},{"int":"3"},{"int":"4"},{"int":"5"},{"int":"6"}],"balance_updates":[{"kind":"contract","contract":"tz1WRFiK6eGNvP3ioWkWeP6JwDaQjj95opnQ","change":"-1000000"},{"kind":"contract","contract":"KT1DwASQY1uTEkzWUShbeQJfKpBdb2ugsE5k","change":"1000000"}],"consumed_gas":"12354","storage_size":"57"}}}],"signature":"edsigu21GWKqpsKLAzGQUozci1ADHCPpfM9QXEE8efC2Sf9w6kcbqmF2YFN2RMokjwvGHguC1RNaPMxpbXNa5RiX8hiXHBsLCoN"}
        """.data(using: .utf8)!
        let tezosClient = TezosClient(remoteNodeURL: Constants.defaultNodeURL, urlSession: networkSessionMock)
        let testStatusExpectation = expectation(description: "Gas decoding")
        let operation = Operation(source: "", kind: .transaction, operationFees: nil)
        operation.counter = 619
        let payload = SignedRunOperationPayload(contents: [operation], branch: "", signature: "")
        let operationMetadata = OperationMetadata(chainId: "", headHash: "", protocolHash: "", addressCounter: 619)
        tezosClient.estimateGas(payload: payload, signedBytesForInjection: "", operationMetadata: operationMetadata, completion: { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            case .success():
                XCTAssertEqual(payload.contents.first?.operationFees?.gasLimit.rpcRepresentation, Mutez(12454).rpcRepresentation)
                testStatusExpectation.fulfill()
            }
        })

        waitForExpectations(timeout: 1)
    }

}
