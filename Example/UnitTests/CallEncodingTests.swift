//
//  CallEncodingTests.swift
//  UnitTests
//
//  Created by Marek Fořt on 11/26/18.
//  Copyright © 2018 Keefer Taylor. All rights reserved.
//

import XCTest
import Foundation
import TezosSwift
@testable import TezosSwift_Example

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

    func testOrSwapCall() {
        guard let input = TezosOr<Bool, String>(left: nil, right: "X") else { XCTFail(); return }
        let contractOperation = ContractOperation(amount: Tez(1), source: "contract", destination: "another_contract", input: input)
        guard let encodedDataString = String(data: try! JSONEncoder().encode(contractOperation), encoding: .utf8) else { XCTFail(); return }
        XCTAssertEqual(encodedDataString, """
        {"amount":"1000000","source":"contract","destination":"another_contract","storage_limit":"0010000","gas_limit":"0010000","fee":"0000000","kind":"transaction","counter":"0","parameters":{"prim":"Right","args":[{"string":"X"}]}}
        """)
    }

    func testKeyHashCall() {
        let contractOperation = ContractOperation(amount: Tez(1), source: "contract", destination: "another_contract", input: "tz1Y3qqTg9HdrzZGbEjiCPmwuZ7fWVxpPtRw")
        guard let encodedDataString = String(data: try! JSONEncoder().encode(contractOperation), encoding: .utf8) else { XCTFail(); return }
        XCTAssertEqual(encodedDataString, """
        {"amount":"1000000","source":"contract","destination":"another_contract","storage_limit":"0010000","gas_limit":"0010000","fee":"0000000","kind":"transaction","counter":"0","parameters":{"string":"tz1Y3qqTg9HdrzZGbEjiCPmwuZ7fWVxpPtRw"}}
        """)
    }

    func testParameterPairCall() {
        let contractOperation = ContractOperation(amount: Tez(1), source: "contract", destination: "another_contract", input: TezosPair<Bool, Bool>(first: true, second: false))
        guard let encodedDataString = String(data: try! JSONEncoder().encode(contractOperation), encoding: .utf8) else { XCTFail(); return }
        XCTAssertEqual(encodedDataString, """
        {"amount":"1000000","source":"contract","destination":"another_contract","storage_limit":"0010000","gas_limit":"0010000","fee":"0000000","kind":"transaction","counter":"0","parameters":{"prim":"Pair","args":[{"prim":"True"},{"prim":"False"}]}}
        """)
    }

    func testMapCall() {
        let contractOperation = ContractOperation(amount: Tez(1), source: "contract", destination: "another_contract", input: TezosMap(pairs: [TezosPair(first: 0, second: 100), TezosPair(first: 2, second: 100)]))
        guard let encodedDataString = String(data: try! JSONEncoder().encode(contractOperation), encoding: .utf8) else { XCTFail(); return }
        XCTAssertEqual(encodedDataString, """
        {"amount":"1000000","source":"contract","destination":"another_contract","storage_limit":"0010000","gas_limit":"0010000","fee":"0000000","kind":"transaction","counter":"0","parameters":[{"prim":"Elt","args":[{"int":"0"},{"int":"100"}]},{"prim":"Elt","args":[{"int":"2"},{"int":"100"}]}]}
        """)
    }

    func testKeyCall() {
        let contractOperation = ContractOperation(amount: Tez(1), source: "contract", destination: "another_contract", input: "edpkuBknW28nW72KG6RoHtYW7p12T6GKc7nAbwYX5m8Wd9sDVC9yav")
        guard let encodedDataString = String(data: try! JSONEncoder().encode(contractOperation), encoding: .utf8) else { XCTFail(); return }
        XCTAssertEqual(encodedDataString, """
        {"amount":"1000000","source":"contract","destination":"another_contract","storage_limit":"0010000","gas_limit":"0010000","fee":"0000000","kind":"transaction","counter":"0","parameters":{"string":"edpkuBknW28nW72KG6RoHtYW7p12T6GKc7nAbwYX5m8Wd9sDVC9yav"}}
        """)
    }

}
