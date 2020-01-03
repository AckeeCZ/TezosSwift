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
        let contractOperation = ContractOperation(amount: Tez(1), source: "contract", destination: "another_contract", input: 10, operationName: "default")
        guard let encodedDataString = String(data: try! JSONEncoder().encode(contractOperation), encoding: .utf8) else { XCTFail(); return }
        XCTAssertEqual(encodedDataString, """
        {"amount":"1000000","source":"contract","destination":"another_contract","storage_limit":"0060000","gas_limit":"0799999","fee":"0001272","kind":"transaction","counter":"0","parameters":{"value":{"int":"10"},"entrypoint":"default"}}
        """)
    }

    func testNilStringCall() {
        let input: String? = nil
        let contractOperation = ContractOperation(amount: Tez(1), source: "contract", destination: "another_contract", input: input, operationName: "default")
        guard let encodedDataString = String(data: try! JSONEncoder().encode(contractOperation), encoding: .utf8) else { XCTFail(); return }
        XCTAssertEqual(encodedDataString, """
        {"amount":"1000000","source":"contract","destination":"another_contract","storage_limit":"0060000","gas_limit":"0799999","fee":"0001272","kind":"transaction","counter":"0","parameters":{"value":{"prim":"Unit"},"entrypoint":"default"}}
        """)
    }

    func testPairBoolCall() {
        let input = TezosPair<Bool, Bool>(first: true, second: false)
        let contractOperation = ContractOperation(amount: Tez(1), source: "contract", destination: "another_contract", input: input, operationName: "default")
        guard let encodedDataString = String(data: try! JSONEncoder().encode(contractOperation), encoding: .utf8) else { XCTFail(); return }
        XCTAssertEqual(encodedDataString, """
        {"amount":"1000000","source":"contract","destination":"another_contract","storage_limit":"0060000","gas_limit":"0799999","fee":"0001272","kind":"transaction","counter":"0","parameters":{"value":{"prim":"Pair","args":[{"prim":"True"},{"prim":"False"}]},"entrypoint":"default"}}
        """)
    }

    func testBytesCall() {
        let input = "".data(using: .utf8)!
        let contractOperation = ContractOperation(amount: Tez(1), source: "contract", destination: "another_contract", input: input, operationName: "default")
        guard let encodedDataString = String(data: try! JSONEncoder().encode(contractOperation), encoding: .utf8) else { XCTFail(); return }
        XCTAssertEqual(encodedDataString, """
        {"amount":"1000000","source":"contract","destination":"another_contract","storage_limit":"0060000","gas_limit":"0799999","fee":"0001272","kind":"transaction","counter":"0","parameters":{"value":{"bytes":""},"entrypoint":"default"}}
        """)
    }

    func testOrSwapCall() {
        guard let input = TezosOr<Bool, String>(left: nil, right: "X") else { XCTFail(); return }
        let contractOperation = ContractOperation(amount: Tez(1), source: "contract", destination: "another_contract", input: input, operationName: "default")
        guard let encodedDataString = String(data: try! JSONEncoder().encode(contractOperation), encoding: .utf8) else { XCTFail(); return }
        XCTAssertEqual(encodedDataString, """
        {"amount":"1000000","source":"contract","destination":"another_contract","storage_limit":"0060000","gas_limit":"0799999","fee":"0001272","kind":"transaction","counter":"0","parameters":{"value":{"prim":"Right","args":[{"string":"X"}]},"entrypoint":"default"}}
        """)
    }

    func testKeyHashCall() {
        let contractOperation = ContractOperation(amount: Tez(1), source: "contract", destination: "another_contract", input: "tz1Y3qqTg9HdrzZGbEjiCPmwuZ7fWVxpPtRw", operationName: "default")
        guard let encodedDataString = String(data: try! JSONEncoder().encode(contractOperation), encoding: .utf8) else { XCTFail(); return }
        XCTAssertEqual(encodedDataString, """
        {"amount":"1000000","source":"contract","destination":"another_contract","storage_limit":"0060000","gas_limit":"0799999","fee":"0001272","kind":"transaction","counter":"0","parameters":{"value":{"string":"tz1Y3qqTg9HdrzZGbEjiCPmwuZ7fWVxpPtRw"},"entrypoint":"default"}}
        """)
    }

    func testParameterPairCall() {
        let contractOperation = ContractOperation(amount: Tez(1), source: "contract", destination: "another_contract", input: TezosPair<Bool, Bool>(first: true, second: false), operationName: "default")
        guard let encodedDataString = String(data: try! JSONEncoder().encode(contractOperation), encoding: .utf8) else { XCTFail(); return }
        XCTAssertEqual(encodedDataString, """
        {"amount":"1000000","source":"contract","destination":"another_contract","storage_limit":"0060000","gas_limit":"0799999","fee":"0001272","kind":"transaction","counter":"0","parameters":{"value":{"prim":"Pair","args":[{"prim":"True"},{"prim":"False"}]},"entrypoint":"default"}}
        """)
    }

    func testMapCall() {
        let contractOperation = ContractOperation(amount: Tez(1), source: "contract", destination: "another_contract", input: TezosMap(pairs: [TezosPair(first: 0, second: 100), TezosPair(first: 2, second: 100)]), operationName: "default")
        guard let encodedDataString = String(data: try! JSONEncoder().encode(contractOperation), encoding: .utf8) else { XCTFail(); return }
        XCTAssertEqual(encodedDataString, """
        {"amount":"1000000","source":"contract","destination":"another_contract","storage_limit":"0060000","gas_limit":"0799999","fee":"0001272","kind":"transaction","counter":"0","parameters":{"value":[{"prim":"Elt","args":[{"int":"0"},{"int":"100"}]},{"prim":"Elt","args":[{"int":"2"},{"int":"100"}]}],"entrypoint":"default"}}
        """)
    }

    func testKeyCall() {
        let contractOperation = ContractOperation(amount: Tez(1), source: "contract", destination: "another_contract", input: "edpkuBknW28nW72KG6RoHtYW7p12T6GKc7nAbwYX5m8Wd9sDVC9yav", operationName: "default")
        guard let encodedDataString = String(data: try! JSONEncoder().encode(contractOperation), encoding: .utf8) else { XCTFail(); return }
        XCTAssertEqual(encodedDataString, """
        {"amount":"1000000","source":"contract","destination":"another_contract","storage_limit":"0060000","gas_limit":"0799999","fee":"0001272","kind":"transaction","counter":"0","parameters":{"value":{"string":"edpkuBknW28nW72KG6RoHtYW7p12T6GKc7nAbwYX5m8Wd9sDVC9yav"},"entrypoint":"default"}}
        """)
    }

    func testTimestampCall() {
        let contractOperation = ContractOperation(amount: Tez(1), source: "contract", destination: "another_contract", input: Date(timeIntervalSince1970: 1502733621), operationName: "default")
        guard let encodedDataString = String(data: try! JSONEncoder().encode(contractOperation), encoding: .utf8) else { XCTFail(); return }
        XCTAssertEqual(encodedDataString, """
        {"amount":"1000000","source":"contract","destination":"another_contract","storage_limit":"0060000","gas_limit":"0799999","fee":"0001272","kind":"transaction","counter":"0","parameters":{"value":{"string":"2017-08-14T18:00:21Z"},"entrypoint":"default"}}
        """)
    }

    func testOptionalStringCall() {
        let optionalString: String? = "hello"
        let contractOperation = ContractOperation(amount: Tez(1), source: "contract", destination: "another_contract", input: optionalString, operationName: "default")
        guard let encodedDataString = String(data: try! JSONEncoder().encode(contractOperation), encoding: .utf8) else { XCTFail(); return }
        XCTAssertEqual(encodedDataString, """
        {"amount":"1000000","source":"contract","destination":"another_contract","storage_limit":"0060000","gas_limit":"0799999","fee":"0001272","kind":"transaction","counter":"0","parameters":{"value":{"string":"hello"},"entrypoint":"default"}}
        """)
    }

    func testNatCall() {
        let contractOperation = ContractOperation(amount: Tez(1), source: "contract", destination: "another_contract", input: UInt(100), operationName: "default")
        guard let encodedDataString = String(data: try! JSONEncoder().encode(contractOperation), encoding: .utf8) else { XCTFail(); return }
        XCTAssertEqual(encodedDataString, """
        {"amount":"1000000","source":"contract","destination":"another_contract","storage_limit":"0060000","gas_limit":"0799999","fee":"0001272","kind":"transaction","counter":"0","parameters":{"value":{"int":"100"},"entrypoint":"default"}}
        """)
    }

    func testSetNatCall() {
        let input: [UInt] = [UInt(1), UInt(2), UInt(3), UInt(4), UInt(5), UInt(6)]
        let contractOperation = ContractOperation(amount: Tez(1), source: "contract", destination: "another_contract", input: input, operationName: "default")
        guard let encodedDataString = String(data: try! JSONEncoder().encode(contractOperation), encoding: .utf8) else { XCTFail(); return }
        XCTAssertEqual(encodedDataString, """
        {"amount":"1000000","source":"contract","destination":"another_contract","storage_limit":"0060000","gas_limit":"0799999","fee":"0001272","kind":"transaction","counter":"0","parameters":{"value":[{"int":"1"},{"int":"2"},{"int":"3"},{"int":"4"},{"int":"5"},{"int":"6"}],"entrypoint":"default"}}
        """)
    }

    func testListIntCall() {
        let input: [UInt] = [1, 2, 3, 4, 5, 6]
        let contractOperation = ContractOperation(amount: Tez(1), source: "contract", destination: "another_contract", input: input, operationName: "default")
        guard let encodedDataString = String(data: try! JSONEncoder().encode(contractOperation), encoding: .utf8) else { XCTFail(); return }
        XCTAssertEqual(encodedDataString, """
        {"amount":"1000000","source":"contract","destination":"another_contract","storage_limit":"0060000","gas_limit":"0799999","fee":"0001272","kind":"transaction","counter":"0","parameters":{"value":[{"int":"1"},{"int":"2"},{"int":"3"},{"int":"4"},{"int":"5"},{"int":"6"}],"entrypoint":"default"}}
        """)
    }

    func testPackUnpackCall() {
        let input: TezosPair<TezosPair<TezosPair<String, [Int]>, [UInt]>, Data> = TezosPair(first: TezosPair(first: TezosPair(first: "toto", second: [3, 7, 9, 1]), second: [UInt(2), UInt(1), UInt(3)].sorted()), second: "hello".data(using: .utf8)!)
        let contractOperation = ContractOperation(amount: Tez(1), source: "contract", destination: "another_contract", input: input, operationName: "default")
        guard let encodedDataString = String(data: try! JSONEncoder().encode(contractOperation), encoding: .utf8) else { XCTFail(); return }
        XCTAssertEqual(encodedDataString, """
        {"amount":"1000000","source":"contract","destination":"another_contract","storage_limit":"0060000","gas_limit":"0799999","fee":"0001272","kind":"transaction","counter":"0","parameters":{"value":{"prim":"Pair","args":[{"prim":"Pair","args":[{"prim":"Pair","args":[{"string":"toto"},[{"int":"3"},{"int":"7"},{"int":"9"},{"int":"1"}]]},[{"int":"1"},{"int":"2"},{"int":"3"}]]},{"bytes":"68656C6C6F"}]},"entrypoint":"default"}}
        """)
    }
}
