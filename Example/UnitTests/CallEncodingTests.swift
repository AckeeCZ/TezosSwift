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
        {"amount":"1000000","source":"contract","destination":"another_contract","storage_limit":"0003000","gas_limit":"0030000","fee":"0030000","kind":"transaction","counter":"0","parameters":{"int":"10"}}
        """)
    }

    func testNilStringCall() {
        let input: String? = nil
        let contractOperation = ContractOperation(amount: Tez(1), source: "contract", destination: "another_contract", input: input)
        guard let encodedDataString = String(data: try! JSONEncoder().encode(contractOperation), encoding: .utf8) else { XCTFail(); return }
        XCTAssertEqual(encodedDataString, """
        {"amount":"1000000","source":"contract","destination":"another_contract","storage_limit":"0003000","gas_limit":"0030000","fee":"0030000","kind":"transaction","counter":"0","parameters":{"prim":"None"}}
        """)
    }

    func testPairBoolCall() {
        let input = TezosPair<Bool, Bool>(first: true, second: false)
        let contractOperation = ContractOperation(amount: Tez(1), source: "contract", destination: "another_contract", input: input)
        guard let encodedDataString = String(data: try! JSONEncoder().encode(contractOperation), encoding: .utf8) else { XCTFail(); return }
        XCTAssertEqual(encodedDataString, """
        {"amount":"1000000","source":"contract","destination":"another_contract","storage_limit":"0003000","gas_limit":"0030000","fee":"0030000","kind":"transaction","counter":"0","parameters":{"prim":"Pair","args":[{"prim":"True"},{"prim":"False"}]}}
        """)
    }

    func testBytesCall() {
        let input = "".data(using: .utf8)!
        let contractOperation = ContractOperation(amount: Tez(1), source: "contract", destination: "another_contract", input: input)
        guard let encodedDataString = String(data: try! JSONEncoder().encode(contractOperation), encoding: .utf8) else { XCTFail(); return }
        XCTAssertEqual(encodedDataString, """
        {"amount":"1000000","source":"contract","destination":"another_contract","storage_limit":"0003000","gas_limit":"0030000","fee":"0030000","kind":"transaction","counter":"0","parameters":{"bytes":""}}
        """)
    }

    func testOrSwapCall() {
        guard let input = TezosOr<Bool, String>(left: nil, right: "X") else { XCTFail(); return }
        let contractOperation = ContractOperation(amount: Tez(1), source: "contract", destination: "another_contract", input: input)
        guard let encodedDataString = String(data: try! JSONEncoder().encode(contractOperation), encoding: .utf8) else { XCTFail(); return }
        XCTAssertEqual(encodedDataString, """
        {"amount":"1000000","source":"contract","destination":"another_contract","storage_limit":"0003000","gas_limit":"0030000","fee":"0030000","kind":"transaction","counter":"0","parameters":{"prim":"Right","args":[{"string":"X"}]}}
        """)
    }

    func testKeyHashCall() {
        let contractOperation = ContractOperation(amount: Tez(1), source: "contract", destination: "another_contract", input: "tz1Y3qqTg9HdrzZGbEjiCPmwuZ7fWVxpPtRw")
        guard let encodedDataString = String(data: try! JSONEncoder().encode(contractOperation), encoding: .utf8) else { XCTFail(); return }
        XCTAssertEqual(encodedDataString, """
        {"amount":"1000000","source":"contract","destination":"another_contract","storage_limit":"0003000","gas_limit":"0030000","fee":"0030000","kind":"transaction","counter":"0","parameters":{"string":"tz1Y3qqTg9HdrzZGbEjiCPmwuZ7fWVxpPtRw"}}
        """)
    }

    func testParameterPairCall() {
        let contractOperation = ContractOperation(amount: Tez(1), source: "contract", destination: "another_contract", input: TezosPair<Bool, Bool>(first: true, second: false))
        guard let encodedDataString = String(data: try! JSONEncoder().encode(contractOperation), encoding: .utf8) else { XCTFail(); return }
        XCTAssertEqual(encodedDataString, """
        {"amount":"1000000","source":"contract","destination":"another_contract","storage_limit":"0003000","gas_limit":"0030000","fee":"0030000","kind":"transaction","counter":"0","parameters":{"prim":"Pair","args":[{"prim":"True"},{"prim":"False"}]}}
        """)
    }

    func testMapCall() {
        let contractOperation = ContractOperation(amount: Tez(1), source: "contract", destination: "another_contract", input: TezosMap(pairs: [TezosPair(first: 0, second: 100), TezosPair(first: 2, second: 100)]))
        guard let encodedDataString = String(data: try! JSONEncoder().encode(contractOperation), encoding: .utf8) else { XCTFail(); return }
        XCTAssertEqual(encodedDataString, """
        {"amount":"1000000","source":"contract","destination":"another_contract","storage_limit":"0003000","gas_limit":"0030000","fee":"0030000","kind":"transaction","counter":"0","parameters":[{"prim":"Elt","args":[{"int":"0"},{"int":"100"}]},{"prim":"Elt","args":[{"int":"2"},{"int":"100"}]}]}
        """)
    }

    func testKeyCall() {
        let contractOperation = ContractOperation(amount: Tez(1), source: "contract", destination: "another_contract", input: "edpkuBknW28nW72KG6RoHtYW7p12T6GKc7nAbwYX5m8Wd9sDVC9yav")
        guard let encodedDataString = String(data: try! JSONEncoder().encode(contractOperation), encoding: .utf8) else { XCTFail(); return }
        XCTAssertEqual(encodedDataString, """
        {"amount":"1000000","source":"contract","destination":"another_contract","storage_limit":"0003000","gas_limit":"0030000","fee":"0030000","kind":"transaction","counter":"0","parameters":{"string":"edpkuBknW28nW72KG6RoHtYW7p12T6GKc7nAbwYX5m8Wd9sDVC9yav"}}
        """)
    }

    func testTimestampCall() {
        let contractOperation = ContractOperation(amount: Tez(1), source: "contract", destination: "another_contract", input: Date(timeIntervalSince1970: 1502733621))
        guard let encodedDataString = String(data: try! JSONEncoder().encode(contractOperation), encoding: .utf8) else { XCTFail(); return }
        XCTAssertEqual(encodedDataString, """
        {"amount":"1000000","source":"contract","destination":"another_contract","storage_limit":"0003000","gas_limit":"0030000","fee":"0030000","kind":"transaction","counter":"0","parameters":{"string":"2017-08-14T18:00:21Z"}}
        """)
    }

    func testOptionalStringCall() {
        let optionalString: String? = "hello"
        let contractOperation = ContractOperation(amount: Tez(1), source: "contract", destination: "another_contract", input: optionalString)
        guard let encodedDataString = String(data: try! JSONEncoder().encode(contractOperation), encoding: .utf8) else { XCTFail(); return }
        XCTAssertEqual(encodedDataString, """
        {"amount":"1000000","source":"contract","destination":"another_contract","storage_limit":"0003000","gas_limit":"0030000","fee":"0030000","kind":"transaction","counter":"0","parameters":{"prim":"Some","args":[{"string":"hello"}]}}
        """)
    }

    func testNatCall() {
        let contractOperation = ContractOperation(amount: Tez(1), source: "contract", destination: "another_contract", input: UInt(100))
        guard let encodedDataString = String(data: try! JSONEncoder().encode(contractOperation), encoding: .utf8) else { XCTFail(); return }
        XCTAssertEqual(encodedDataString, """
        {"amount":"1000000","source":"contract","destination":"another_contract","storage_limit":"0003000","gas_limit":"0030000","fee":"0030000","kind":"transaction","counter":"0","parameters":{"int":"100"}}
        """)
    }

    func testSetNatCall() {
        let input: [UInt] = [UInt(1), UInt(2), UInt(3), UInt(4), UInt(5), UInt(6)]
        let contractOperation = ContractOperation(amount: Tez(1), source: "contract", destination: "another_contract", input: input)
        guard let encodedDataString = String(data: try! JSONEncoder().encode(contractOperation), encoding: .utf8) else { XCTFail(); return }
        XCTAssertEqual(encodedDataString, """
        {"amount":"1000000","source":"contract","destination":"another_contract","storage_limit":"0003000","gas_limit":"0030000","fee":"0030000","kind":"transaction","counter":"0","parameters":[{"int":"1"},{"int":"2"},{"int":"3"},{"int":"4"},{"int":"5"},{"int":"6"}]}
        """)
    }

    func testListIntCall() {
        let input: [UInt] = [1, 2, 3, 4, 5, 6]
        let contractOperation = ContractOperation(amount: Tez(1), source: "contract", destination: "another_contract", input: input)
        guard let encodedDataString = String(data: try! JSONEncoder().encode(contractOperation), encoding: .utf8) else { XCTFail(); return }
        XCTAssertEqual(encodedDataString, """
        {"amount":"1000000","source":"contract","destination":"another_contract","storage_limit":"0003000","gas_limit":"0030000","fee":"0030000","kind":"transaction","counter":"0","parameters":[{"int":"1"},{"int":"2"},{"int":"3"},{"int":"4"},{"int":"5"},{"int":"6"}]}
        """)
    }

    func testPackUnpackCall() {
        let input: TezosPair<TezosPair<TezosPair<String, [Int]>, [UInt]>, Data> = TezosPair(first: TezosPair(first: TezosPair(first: "toto", second: [3, 7, 9, 1]), second: [UInt(2), UInt(1), UInt(3)].sorted()), second: "hello".data(using: .utf8)!)
        let contractOperation = ContractOperation(amount: Tez(1), source: "contract", destination: "another_contract", input: input)
        guard let encodedDataString = String(data: try! JSONEncoder().encode(contractOperation), encoding: .utf8) else { XCTFail(); return }
        XCTAssertEqual(encodedDataString, """
        {"amount":"1000000","source":"contract","destination":"another_contract","storage_limit":"0003000","gas_limit":"0030000","fee":"0030000","kind":"transaction","counter":"0","parameters":{"prim":"Pair","args":[{"prim":"Pair","args":[{"prim":"Pair","args":[{"string":"toto"},[{"int":"3"},{"int":"7"},{"int":"9"},{"int":"1"}]]},[{"int":"1"},{"int":"2"},{"int":"3"}]]},{"bytes":"68656C6C6F"}]}}
        """)
    }
}
