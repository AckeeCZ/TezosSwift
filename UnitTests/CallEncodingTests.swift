//
//  CallEncodingTests.swift
//  UnitTests
//
//  Created by Marek Fořt on 11/26/18.
//  Copyright © 2018 Keefer Taylor. All rights reserved.
//

import XCTest
import Foundation
@testable import TezosSwift

class CallEncodingTests: XCTestCase {

    func testIntCall() {
        let contractOperation = ContractOperation(amount: Tez(1), source: "contract", destination: "another_contract", input: 10)
        guard let encodedDataString = String(data: try! JSONEncoder().encode(contractOperation), encoding: .utf8) else { XCTFail(); return }
        XCTAssertEqual(encodedDataString, """
        {"amount":"1000000","source":"contract","destination":"another_contract","storage_limit":"0010000","gas_limit":"0010000","fee":"0000000","kind":"transaction","counter":"0","parameters":{"int":"10"}}
        """)
    }

    func testNilStringCall() {
        let input: String? = nil
        let contractOperation = ContractOperation(amount: Tez(1), source: "contract", destination: "another_contract", input: input)
        guard let encodedDataString = String(data: try! JSONEncoder().encode(contractOperation), encoding: .utf8) else { XCTFail(); return }
        XCTAssertEqual(encodedDataString, """
        {"amount":"1000000","source":"contract","destination":"another_contract","storage_limit":"0010000","gas_limit":"0010000","fee":"0000000","kind":"transaction","counter":"0","parameters":{"prim":"None"}}
        """)
    }

    func testPairBoolCall() {
        let input = TezosPair<Bool, Bool>(first: true, second: false)
        let contractOperation = ContractOperation(amount: Tez(1), source: "contract", destination: "another_contract", input: input)
        guard let encodedDataString = String(data: try! JSONEncoder().encode(contractOperation), encoding: .utf8) else { XCTFail(); return }
        XCTAssertEqual(encodedDataString, """
        {"amount":"1000000","source":"contract","destination":"another_contract","storage_limit":"0010000","gas_limit":"0010000","fee":"0000000","kind":"transaction","counter":"0","parameters":{"prim":"Pair","args":[{"prim":"True"},{"prim":"False"}]}}
        """)
    }

    func testBytesCall() {
        let input = "".data(using: .utf8)!
        let contractOperation = ContractOperation(amount: Tez(1), source: "contract", destination: "another_contract", input: input)
        guard let encodedDataString = String(data: try! JSONEncoder().encode(contractOperation), encoding: .utf8) else { XCTFail(); return }
        XCTAssertEqual(encodedDataString, """
        {"amount":"1000000","source":"contract","destination":"another_contract","storage_limit":"0010000","gas_limit":"0010000","fee":"0000000","kind":"transaction","counter":"0","parameters":{"bytes":""}}
        """)
    }

}
